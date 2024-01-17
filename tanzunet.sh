#!/bin/bash
# doc https://network.pivotal.io/docs/api

TANZU_NET_API_ENDPOINT=https://network.tanzu.vmware.com/api/v2

echo "######Products List######" 
curl -s $TANZU_NET_API_ENDPOINT/products | jq -r '.products[] | (.id|tostring) + "\t" + .slug'

read -p "Choose product id or name: " product 
curl -s $TANZU_NET_API_ENDPOINT/products/$product | jq .

echo "######Release List######" 
curl -s $TANZU_NET_API_ENDPOINT/products/$product/releases | jq -r '.releases[] | (.id|tostring) + "\t" + .version' | sort 

read -p "Choose release id: " release 
curl -s $TANZU_NET_API_ENDPOINT/products/$product/releases/$release | jq . 

echo "######Product File######" 
curl -s $TANZU_NET_API_ENDPOINT/products/$product/releases/$release/product_files | jq -r '.product_files[] | (.id|tostring) + "\t" + .name + "\t"'

if [ -z "$TANZUNET_REFRESH_TOKEN" ]; then
    read -p "Authorization is required for downloading, please enter Tanzu Network refresh token: " -s tanzunet_refresh_token
else
    tanzunet_refresh_token=$TANZUNET_REFRESH_TOKEN
fi

tanzunet_access_token=$(curl -s -X POST $TANZU_NET_API_ENDPOINT/authentication/access_tokens -d "{\"refresh_token\":\"$tanzunet_refresh_token\"}" | awk -F: '{print $2}' | sed -e 's/"//g' -e 's/}//g' )

echo -e "\n"
read -p "Choose file to download : " file_id
curl -H "Authorization: Bearer $tanzunet_access_token" -LJO $TANZU_NET_API_ENDPOINT/products/$product/releases/$release/product_files/$file_id/download

# echo "######Release Dependencies######" 
# curl -s $TANZU_NET_API_ENDPOINT/products/$product/releases/$release/dependencies | jq .