#!/bin/bash
#
echo Resetting all current allowed connections
# Reset all allowed connections
#
bash <(curl -s -H "Authorization: Bearer $TOKEN" "https://securecloud.tufin.io/api/ben-demo-env/test/scripts/reset-policy")
#
echo Placing into Learn Mode
# Place into Learn mode
#
#
curl --location --request PUT "https://ben-demo-env.securecloud.tufin.io/lighthouse/ben-demo-env/test/project-settings?mode=learning" --header "Authorization: Bearer $TOKEN" --header "Content-Type: application/json"
#
echo Exercising Customer App
# Exercise the app here - customer
#
curl -s "https://34.120.108.78:80/customer/"
curl -s "https://34.120.108.78:80/balance"
#
echo Exercising Admin App
# Exercise the app here - admin
#
curl -s "https://34.120.108.78:80/admin/"
curl -s "https://34.120.108.78:80/boa/admin/accounts"
curl -s "https://34.120.108.78:80/time"
#
echo Moving new connections to allowed connections
# Move new connections to allowed connections
#
bash <(curl -s -H "Authorization: Bearer $TOKEN" "https://securecloud.tufin.io/api/ben-demo-env/test/scripts/commit-policy")
#
echo Pulling New Policy
# Pull New Policy
#
curl 'https://ben-demo-env.securecloud.tufin.io/midas/ben-demo-env/test/network-policies?egress=true&namespaces=default,data' -H "Authorization: Bearer $TOKEN" > temp/NetworkPolicy.yaml
#
echo Splitting YAML file 
# This splits the yaml file into sections to be moved to the repos
#
#
awk '/apiVersion/{if(FN)close(FN);FN="/Users/ben.grissinger/Documents/generic-bank-test/APIs/temp/NetworkPolicy"++i".yaml";p=1}p{print >FN}/Ingress/{p=0}' temp/NetworkPolicy.yaml
#
# Now we need to check compare to existing versions
#
# vimdiff jcampbell41 jcampbell51
