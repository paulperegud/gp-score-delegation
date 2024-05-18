#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.web3 python3Packages.setuptools python3Packages.click

from web3 import Web3
from eth_account.messages import encode_defunct
from eth_keys import keys

w3 = Web3()

def arr(b):
    return [ x for x in b ]

msg = "delegate"

acc = w3.eth.account.from_key(b'1' * 32)
pk = keys.PrivateKey(acc.key)

message = encode_defunct(text=msg)
signed_message = w3.eth.account.sign_message(message, private_key=acc.key)
print(f"message: {msg}")
print(f"privkey: {acc.privateKey.hex()}")
print(f"pubkey: {pk.public_key}")
print(f"pubkey x: {arr(pk.public_key[:32])}")
print(f"pubkey y: {arr(pk.public_key[32:])}")
print(f"address: {acc.address}")
print(f"msg hash: {arr(signed_message.messageHash)}")
print(f"signature: {arr(signed_message.signature)}")
print(f"nullifier web3: {arr(Web3.keccak(signed_message.signature[:64]))}")
