#!/bin/bash
set -eux

docker build -t "beta-ice-example:latest" .
docker run -it beta-ice-example:latest ./run.sh
