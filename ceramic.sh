#!/bin/bash

docker pull ceramicnetwork/js-ceramic:latest

docker run -d \
       -p 7007:7007 \
       -v /home/pepesza/code/gp-delegation/daemon_config:/root/.ceramic/daemon.config.json \
       -v /home/pepesza/code/gp-delegation/logs:/root/.ceramic/logs \
       -v /home/pepesza/code/gp-delegation/statestore:/root/.ceramic/statestore \
       -e NODE_ENV=production \
       -e CERAMIC_INDEXING_DB_URI=postgres://postgres:mysecretpassword@localhost:5432/dbname \
       --name ceramic \
       ceramicnetwork/js-ceramic --ipfs-api http://localhost:5001
