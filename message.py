#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.web3 python3Packages.setuptools python3Packages.click python3Packages.toml

from web3 import Web3
from eth_account.messages import encode_defunct
from eth_keys import keys
import toml

w3 = Web3()

def arr(b):
    return [ str(x) for x in b ]

def dearr(arr):
    return bytes([ int(x) for x in arr ])

def null_terminated_arr(b, target_len=3):
    b_len = len(str(b))
    assert(b_len <= target_len)
    left = [ x for x in str(b) ]
    right = [ '0' for _ in range(target_len - b_len) ]
    return left + right

prover = dict() # this will become Prover.toml

# Each delegation only works for particular domain. This is an example domain.
nullifier_domain = "I delegate my Gitcoin Passport score for Gitcoin Grants epoch 4"

# delegator
alice_acc = w3.eth.account.from_key(b'1' * 32)
alice_pk = keys.PrivateKey(alice_acc.key)

message = encode_defunct(text=nullifier_domain)
signed_message = w3.eth.account.sign_message(message, private_key=alice_acc.key)

preimage = dict()
preimage['deleg_pubx'] = arr(alice_pk.public_key[:32])
preimage['deleg_puby'] = arr(alice_pk.public_key[32:])
preimage['signature'] = arr(signed_message.signature[:64])
prover['preimage'] = preimage
prover['score'] = 25
prover['hashed_message'] = arr(signed_message.messageHash)
prover['nullifier'] = arr(Web3.keccak(signed_message.signature[:64]))

# this is certifier's address (Gitcoin Passport signing key)
cert = w3.eth.account.from_key(b'2' * 32)
cert_pk = keys.PrivateKey(cert.key)

prover['cert_pubx'] = arr(cert_pk.public_key[:32])
prover['cert_puby'] = arr(cert_pk.public_key[32:])
stamps = []

for i in range(1, 11):
    score = i
    msg = f"{i}"
    # TODO: replace with EIP712
    message = encode_defunct(text=msg)
    signed_message = w3.eth.account.sign_message(message, private_key=cert.key)
    stamp = {
        'signature': arr(signed_message.signature[:64]),
        'hashed_message': arr(signed_message.messageHash),
        'score': score,
        'score_string': null_terminated_arr(score, 3)
    }
    stamps.append(stamp)

sorted_stamps = sorted(stamps, key=lambda stamp: dearr(stamp['signature']))
prover['stamps'] = sorted_stamps

with open('Prover.toml', 'w', encoding='utf8') as f:
    f.write(toml.dumps(prover))
