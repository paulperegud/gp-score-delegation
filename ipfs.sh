#!/bin/bash

docker pull ceramicnetwork/go-ipfs-daemon:latest

docker run \
  -p 5001:5001 \
  -p 8011:8011 \
  -v /home/pepesza/code/gp-delegation/vol_ipfs:/data/ipfs \
  --name ipfs \
  ceramicnetwork/go-ipfs-daemon
