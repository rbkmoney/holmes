#!/usr/bin/env python3

import json
import os
import sys
import getopt
import subprocess


def call(args, raw=False, stdin=""):
    if not raw:
        args = args.split(" ")
    handler = subprocess.Popen(args, stdout=subprocess.PIPE, stdin=subprocess.PIPE, encoding="utf-8")
    out, _err = handler.communicate(input=stdin)
    assert out is not None
    if handler.returncode != 0:
        raise Exception(f"oops args {args} failed with code {handler.returncode}")
    return out


def call_keyring(func, *args):
    cds = os.environ["CDS"]
    thrift_port = os.environ["THRIFT_PORT"]
    json_args = [json.dumps(arg) for arg in args]
    woorl_args = [
        "woorl", "-s", "cds_proto/proto/keyring.thrift",
        f"http://{cds}:{thrift_port}/v2/keyring",
        "Keyring", func, *json_args
    ]
    return call(woorl_args, raw=True)


def decrypt_and_sign(shareholder_id, encrypted_share):
    decrypted_share = strip_line(
        call(f"step crypto jwe decrypt --key {shareholder_id}.enc.json", stdin=encrypted_share)
    )
    assert decrypted_share != ""
    return strip_line(call(f"step crypto jws sign --key {shareholder_id}.sig.json -", stdin=decrypted_share))


def strip_line(string):
    result = string.strip("\n")
    assert len(result.split("\n")) == 1
    return result


def init():
    encrypted_shares_json = call_keyring("StartInit", 2)

    encrypted_mk_shares = json.loads(encrypted_shares_json)
    result = None

    shares = {}

    for encrypted_mk_share in encrypted_mk_shares:
        shareholder_id = encrypted_mk_share['id']
        encrypted_share = encrypted_mk_share['encrypted_share']
        signed_share = decrypt_and_sign(shareholder_id, encrypted_share)
        result = json.loads(call_keyring("ValidateInit", shareholder_id, signed_share))
        if "success" not in result and "more_keys_needed" not in result:
            print("Error! Exception returned: {}".format(result))
            exit(1)
        shares[shareholder_id] = signed_share
    assert "success" in result, f"Last ValidateInit return not Success: {result}"
    print(json.dumps(shares))


def unlock():
    shares = json.loads(sys.stdin.read())

    call_keyring("StartUnlock")

    for shareholder_id in list(shares):
        signed_share = shares[shareholder_id]
        result = json.loads(call_keyring("ConfirmUnlock", shareholder_id, signed_share))
        if "success" in result:
            break
        elif "more_keys_needed" not in result:
            print("Error! Exception returned: {}".format(result))
            exit(1)
    else:
        print("Keyring is still locked")
        exit(1)


def get_state():
    print(call_keyring("GetState"))


def main(argv):
    help_promt = "usage: keyring.py {init | unlock | state} [-h | --help]"
    try:
        opts, args = getopt.getopt(argv, "h", ["--help"])
    except getopt.GetoptError:
        print(help_promt)
        exit(2)
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            print(help_promt)
            exit()
    if len(args) == 0:
        print(help_promt)
        exit(2)
    elif args[0] == 'init':
        init()
    elif args[0] == 'unlock':
        unlock()
    elif args[0] == 'state':
        get_state()


if __name__ == "__main__":
    main(sys.argv[1:])
