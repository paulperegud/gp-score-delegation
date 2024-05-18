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

msg = "delegate"

acc = w3.eth.account.from_key(b'1' * 32)
pk = keys.PrivateKey(acc.key)

message = encode_defunct(text=msg)
signed_message = w3.eth.account.sign_message(message, private_key=acc.key)

prover = dict()
preimage = dict()
preimage['pub_pubx'] = arr(pk.public_key[:32])
preimage['pub_puby'] = arr(pk.public_key[32:])
preimage['signature'] = arr(signed_message.signature[:64])
prover['preimage'] = preimage
prover['score'] = 25
prover['hashed_message'] = arr(signed_message.messageHash)
prover['nullifier'] = arr(Web3.keccak(signed_message.signature[:64]))

cert = w3.eth.account.from_key(b'2' * 32)
cert_pk = keys.PrivateKey(cert.key)

prover['cert_pubx'] = arr(cert_pk.public_key[:32])
prover['cert_puby'] = arr(cert_pk.public_key[32:])
stamps = []


for i in range(10):
    score = i
    msg = f"{i}"
    message = encode_defunct(text=msg)
    signed_message = w3.eth.account.sign_message(message, private_key=cert.key)
    stamp = {
        'signature': arr(signed_message.signature[:64]),
        'hashed_message': arr(signed_message.messageHash),
        'score': score,
    }
    stamps.append(stamp)

sorted_stamps = sorted(stamps, key=lambda stamp: dearr(stamp['signature']))
prover['stamps'] = sorted_stamps

with open('Prover.toml', 'w', encoding='utf8') as f:
    f.write(toml.dumps(prover))
