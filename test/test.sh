#!/bin/bash -x

user="mytestuser"
key="mytestkey"
host="mytesthost"

group="mytestgroup"
artifact="test_artifact.txt"

curl -X GET --user $user:$key -v http://$host/artifacts/v1/groups

curl -X GET --user $user:$key -v http://$host/artifacts/v1/groups/$group

curl -X PUT --user $user:$key -d 'method=file' -v http://$host/artifacts/v1/groups/$group

curl -X PUT --user $user:$key -v --upload-file test_artifact.txt http://$host/artifacts/v1/data/$group/$artifact

