#!/bin/bash
for FILE in "$@"
do
curl -i -X POST -H "Content-Type: multipart/form-data" -F "data=@$FILE" http://localhost:8080/repository/deployments
done