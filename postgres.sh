#!/bin/bash

docker pull postgres

docker run -d \
       -e POSTGRES_PASSWORD=mysecretpassword \
       -e PGDATA=/var/lib/postgresql/data/pgdata \
       -v /home/pepesza/code/gp-delegation/vol_postgres:/var/lib/postgresql/data \
       -p 5432:5432 \
       --name postgres \
       postgres
