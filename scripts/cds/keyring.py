#!/usr/bin/env python

import json
import os
import sys
import getopt
import subprocess
import six


def ensure_binary(s, encoding='utf-8', errors='strict'):
    """Coerce **s** to six.binary_type.
    For Python 2:
      - `unicode` -> encoded to `str`
      - `str` -> `str`
    For Python 3:
      - `str` -> encoded to `bytes`
      - `bytes` -> `bytes`
    """
    if isinstance(s, six.text_type):
        return s.encode(encoding, errors)
    elif isinstance(s, six.binary_type):
        return s
    else:
        raise TypeError("not expecting type '%s'" % type(s))


def ensure_str(s, encoding='utf-8', errors='strict'):
    """Coerce *s* to `str`.
    For Python 2:
      - `unicode` -> encoded to `str`
      - `str` -> `str`
    For Python 3:
      - `str` -> `str`
      - `bytes` -> decoded to `str`
    """
    if not isinstance(s, (six.text_type, six.binary_type)):
        raise TypeError("not expecting type '%s'" % type(s))
    if six.PY2 and isinstance(s, six.text_type):
        s = s.encode(encoding, errors)
    elif six.PY3 and isinstance(s, six.binary_type):
        s = s.decode(encoding, errors)
    return s


def call(args, raw=False, stdin=""):
    if not raw:
        args = args.split(" ")
    handler = subprocess.Popen(args, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    stdin = ensure_binary(stdin)
    out, _err = handler.communicate(input=stdin)
    assert out is not None
    out = ensure_str(out)
    if handler.returncode != 0:
        raise Exception("oops args {} failed with code {} and result {}"
                        .format(args, handler.returncode, out))
    return out


def call_keyring(cds_address, func, *args):
    thrift_port = os.environ["THRIFT_PORT"]
    json_args = [json.dumps(arg) for arg in args]
    woorl_args = \
        [
            "woorl", "-s", "cds_proto/proto/keyring.thrift",
            "http://{}:{}/v2/keyring".format(cds_address, thrift_port),
            "KeyringManagement", func
        ] + json_args
    return call(woorl_args, raw=True)


def decrypt_and_sign(shareholder_id, encrypted_share):
    decrypted_share = strip_line(
        call("step crypto jwe decrypt --key scripts/cds/{}.enc.json".format(shareholder_id),
             stdin=encrypted_share)
    )
    assert decrypted_share != ""
    return strip_line(
        call("step crypto jws sign --key scripts/cds/{}.sig.json -".format(shareholder_id),
             stdin=decrypted_share))


def strip_line(string):
    result = string.strip("\n")
    assert len(result.split("\n")) == 1
    return result


def init(cds_address):
    encrypted_shares_json = call_keyring(cds_address, "StartInit", 2)

    encrypted_mk_shares = json.loads(encrypted_shares_json)
    result = None

    shares = {}

    for encrypted_mk_share in encrypted_mk_shares:
        shareholder_id = encrypted_mk_share['id']
        encrypted_share = encrypted_mk_share['encrypted_share']
        signed_share = {
            "id": shareholder_id,
            "signed_share": decrypt_and_sign(shareholder_id, encrypted_share)
        }
        result = json.loads(call_keyring(cds_address, "ValidateInit", signed_share))
        if "success" not in result and "more_keys_needed" not in result:
            six.print_("Error! Exception returned: {}".format(result))
            exit(1)
        shares[shareholder_id] = signed_share
    assert "success" in result, "Last ValidateInit return not Success: {}".format(result)
    six.print_(json.dumps(shares))


def unlock(cds_address):
    shares = json.loads(sys.stdin.read())

    call_keyring(cds_address, "StartUnlock")

    for shareholder_id in list(shares):
        signed_share = {
            "id": shareholder_id,
            "signed_share": shares[shareholder_id]
        }
        result = json.loads(call_keyring(cds_address, "ConfirmUnlock", signed_share))
        if "success" in result:
            break
        elif "more_keys_needed" not in result:
            six.print_("Error! Exception returned: {}".format(result))
            exit(1)
    else:
        six.print_("Keyring is still locked")
        exit(1)


def get_state(cds_address):
    six.print_(call_keyring(cds_address, "GetState"))


def main(argv):
    address = os.environ["CDS"]
    help_promt = "usage: keyring.py {init | unlock | state} [-h | --help]"
    try:
        opts, args = getopt.getopt(argv, "ha:", ["help", "address="])
    except getopt.GetoptError:
        six.print_(help_promt)
        exit(2)
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            six.print_(help_promt)
            exit()
        if opt in ('-a', '--address'):
            address = arg
    if len(args) == 0:
        six.print_(help_promt)
        exit(2)
    elif args[0] == 'init':
        init(address)
    elif args[0] == 'unlock':
        unlock(address)
    elif args[0] == 'state':
        get_state(address)


if __name__ == "__main__":
    main(sys.argv[1:])
