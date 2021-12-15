#!/bin/env python
#
# Give me a list of party ids and I'll try to make first class contractor entities from those
# contractors defined only within context of historical contracts.
#

import os
import sys
import argparse
import subprocess
import itertools
import json
import uuid
import copy

escbw = "\x1b[1;37m"
escbr = "\x1b[1;31m"
escby = "\x1b[1;33m"
escrs = "\x1b[0m"

def em(arg):
    return "{bw}{arg}{rs}".format(bw=escbw,arg=arg,rs=escrs)

def err(*args):
    prefix = "{br}[ERROR]{rs}".format(br=escbr, rs=escrs)
    print(prefix, *args)

def info(*args):
    print(em("[INFO]"), *args)

cwd = os.path.dirname(os.path.realpath(__file__))

parser = argparse.ArgumentParser()
parser.add_argument('-n', '--dry-run', action='store_true', default=False,
    help="do not actually do anything")
parser.add_argument('-d', '--debug', action='store_true', default=False,
    help="print command invocation traces")
parser.add_argument('-i', '--input-file', nargs='?',
    type=argparse.FileType('r', encoding='UTF-8'),
    help="a file to read party ids from")
parser.add_argument('party_id', nargs='*',
    help="which parties to act upon?")

opts = parser.parse_args()

if opts.input_file:
    parties = [l.strip() for l in opts.input_file.readlines()]
else:
    parties = opts.party_id

def sh(*args):
    if opts.debug:
        print('[SHELL]', *args)
    return subprocess.check_output(' '.join(args), shell=True, text=True, cwd=cwd)

def cmd(*args):
    if opts.debug:
        print('[CMD]', *args)
    return subprocess.check_output(args, text=True, cwd=cwd)

woorl_cmd = sh('test -f ./woorlrc && source ./woorlrc ; echo ${WOORL[@]:-woorl}').strip('\n').split(' ')

def woorl(*args, dry_run_result=None):
    if not opts.dry_run:
        return cmd(*itertools.chain(woorl_cmd, args))
    else:
        return dry_run_result

def mk_contractor(contractor_id, contractor):
    return {
        'contractor_modification': {
            'id': contractor_id,
            'modification': {
                'creation': contractor
            }
        }
    }


def mk_change_contractor(contract_id, contractor_id):
    return {
        'contract_modification': {
            'id': contract_id,
            'modification': {
                'contractor_modification': contractor_id
            }
        }
    }


userinfo = {'id': 'woorl', 'type': {'service_user': {}}}

partymgmt_url = 'http://{host}:{port}/v1/processing/partymgmt'.format(
    host=os.environ.get('HELLGATE', 'hellgate'),
    port=os.environ.get('HELLGATE_PORT', 8022)
)

def migrate_party(party_id):
    info("[%s]" % party_id, "migrating ...")
    party = json.loads(sh('./hellgate/get-party-state.sh', party_id))

    if 'blocked' in party['blocking']:
        return err("[%s]" % party_id, "blocked")

    changeset = []
    contractors = {}
    if len(party['contractors']) > 0:
        contractors = copy.deepcopy(party['contractors'])

    if len(party['contracts']) > 0:
        for contract_id, contract in party['contracts'].items():
            if 'contractor_id' not in contract:
                contractor_next = contract['contractor']
                for contractor_id, contractor in contractors.items():
                    if contractor == contractor_next:
                        changeset.append(mk_change_contractor(contract_id, contractor_id))
                        break
                else:
                    contractor_id = str(uuid.uuid4())
                    contractors[contractor_id] = copy.deepcopy(contractor_next)
                    changeset.append(mk_contractor(contractor_id, contractor_next))
                    changeset.append(mk_change_contractor(contract_id, contractor_id))

    if len(changeset) > 0:

        info("[%s]" % party_id, "submitting changeset:", changeset)

        claim = json.loads(woorl(
            '-s', '../damsel/ebin/dmsl_payment_processing_thrift.beam',
            partymgmt_url, 'PartyManagement', 'CreateClaim',
            json.dumps(userinfo),
            json.dumps(party_id),
            json.dumps(changeset),
            dry_run_result='{"id":42, "revision":1}'
        ))

        info("[%s]" % party_id, "claim %s created, revision %i" % (claim['id'], claim['revision']))

        woorl(
            '-s', '../damsel/ebin/dmsl_payment_processing_thrift.beam',
            partymgmt_url, 'PartyManagement', 'AcceptClaim',
            json.dumps(userinfo),
            json.dumps(party_id),
            json.dumps(claim['id']),
            json.dumps(claim['revision'])
        )

        info("[%s]" % party_id, "claim %s accepted" % claim['id'])

    info("[%s]" % party_id, "done")

for party_id in parties:
    migrate_party(party_id)
