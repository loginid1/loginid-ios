#!/bin/bash

set -e

rm -rf ./loginid-fido2

git clone git@gitlab.com:loginid/software/loginid-fido2.git
cp ./loginid-fido2/api/rest/openapi3.yaml ./openapi.yaml

npm run generate

rm -rf ./loginid-fido2
rm ./openapi.yaml ./mod-openapi.yaml
