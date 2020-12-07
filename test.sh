#!/usr/bin/env bash
docker run \
  --env-file env/definet \
  --publish-all \
  --name akash-on-akash \
  --rm \
  akash-on-akash:local
