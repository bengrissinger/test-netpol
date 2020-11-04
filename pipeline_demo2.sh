#!/bin/bash
#Get variables for scripts
#we need Bearer Token, Tenant name and Project name.

echo Enter Your Tenant Name:
read tenant

echo Enter Your Project Name:
read project

echo Enter your All CI Token:
read token

TENANT=$(echo $tenant)
PROJECT=$(echo $project)
TOKEN=$(echo $token)

echo Here are your details:
echo 
echo
echo Tenant = $TENANT
echo Project = $PROJECT
echo Token = $TOKEN
echo
echo
while true; do
    read -p "Do you wish to continue? " yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo
echo Making temporary directory in home directory called securecloud-temp
echo
# Making new temp directory
mkdir ~/securecloud-temp
#
echo
echo Resetting all current allowed connections
echo
# Reset all allowed connections
#
bash <(curl -s -H "Authorization: Bearer $TOKEN" "https://securecloud.tufin.io/api/$TENANT/$PROJECT/scripts/reset-policy")
#
echo
echo Placing into Learn Mode
echo
# Place into Learn mode
#
#
curl --location --request PUT "https://campbell-systems.securecloud.tufin.io/lighthouse/$TENANT/$PROJECT/project-settings?mode=learning" --header "Authorization: Bearer $TOKEN" --header "Content-Type: application/json"
#
echo
echo Exercising Customer App
echo
# Exercise the app here - customer
#
curl -s "http://34.120.36.144:80/customer/"
curl -s "http://34.120.36.144:80/balance"
#
echo
echo Exercising Admin App
echo
# Exercise the app here - admin
#
curl -s "http://34.120.36.144:80/admin/"
curl -s "http://34.120.36.144:80/boa/admin/accounts"
curl -s "http://34.120.36.144:80/time"
#
echo
echo Moving new connections to allowed connections
echo
# Move new connections to allowed connections
#
bash <(curl -s -H "Authorization: Bearer $TOKEN" "https://securecloud.tufin.io/api/$TENANT/$PROJECT/scripts/commit-policy")
#
#
echo
echo Pulling New Policy
echo
# Pull New Policy
#
curl "https://$TENANT.securecloud.tufin.io/midas/$TENANT/$PROJECT/network-policies?egress=true&namespaces=default,data" -H "Authorization: Bearer $TOKEN" > ~/securecloud-temp/NetworkPolicy.yaml
#
echo
echo Splitting YAML file
echo
# This splits the yaml file into sections to be moved to the repos
#
#
awk '/apiVersion/{if(FN)close(FN);FN="NetworkPolicy"++i".yaml";p=1}p{print > FN}/Ingress/{p=0}' ~/securecloud-temp/NetworkPolicy.yaml  && mv NetworkPolicy*.yaml ~/securecloud-temp/
#
# Now we need to check compare to existing versions
#
# vimdiff NetworkPolicy1 NetworkPolicy51
