#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.web3 python3Packages.setuptools python3Packages.click python3Packages.toml

from web3 import Web3
from eth_account.messages import encode_defunct
from eth_keys import keys
import toml

w3 = Web3()

def arr(b):
    return [ str(x) for x in b ]

msg = "delegate"

acc = w3.eth.account.from_key(b'1' * 32)
pk = keys.PrivateKey(acc.key)

message = encode_defunct(text=msg)
signed_message = w3.eth.account.sign_message(message, private_key=acc.key)

prover = dict()
preimage = dict()
preimage['pub_key_x'] = arr(pk.public_key[:32])
preimage['pub_key_y'] = arr(pk.public_key[32:])
preimage['signature'] = arr(signed_message.signature[:64])
prover['preimage'] = preimage
prover['hashed_message'] = arr(signed_message.messageHash)
prover['nullifier'] = arr(Web3.keccak(signed_message.signature[:64]))

with open('Prover.toml', 'w', encoding='utf8') as f: 
    f.write(toml.dumps(prover))
