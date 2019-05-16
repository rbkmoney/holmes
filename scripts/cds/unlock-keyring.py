import subprocess
import os
import json
import sys


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
        "woorl", "-s", "damsel/proto/cds.thrift",
        f"http://{cds}:{thrift_port}/v1/keyring",
        "Keyring", func, *json_args
    ]
    return call(woorl_args, raw=True)


def main():
    shares = json.loads(sys.stdin.read())

    call_keyring("StartUnlock")

    for shareholder_id in list(shares):
        signed_share = shares[shareholder_id]
        result = json.loads(call_keyring("ConfirmUnlock", shareholder_id, signed_share))
        if "success" not in result and "more_keys_needed" not in result:
            print("Error! Exception returned: {}".format(result))
            exit(1)
        if "success" in result:
            break


if __name__ == "__main__":
    main()
