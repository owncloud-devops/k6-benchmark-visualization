#!/bin/sh

# install dependencies

apk add curl jq

# script directory
SCRIPT_DIR=$(dirname "$0")

# delete alert config

echo "delete alerts config"
curl 'http://grafana:3000/api/alertmanager/grafana/config/api/v1/alerts' \
-X 'DELETE' \
-H 'accept: application/json, text/plain, */*' \
-H 'x-grafana-org-id: 1' \
--insecure \
--silent \
-u $GF_SECURITY_ADMIN_USER:$GF_SECURITY_ADMIN_PASSWORD \
| jq .

# create alert config

echo "post alerts config from file"
curl 'http://grafana:3000/api/alertmanager/grafana/config/api/v1/alerts' \
-X 'POST' \
-H 'accept: application/json, text/plain, */*' \
-H 'content-type: application/json' \
-H 'x-grafana-org-id: 1' \
--data-binary "@$SCRIPT_DIR/contact-points.json" \
--insecure \
--silent \
-u $GF_SECURITY_ADMIN_USER:$GF_SECURITY_ADMIN_PASSWORD \
| jq .


# delete existing alert rules

echo "get alert rules"
rulefolders=$(curl 'http://grafana:3000/api/ruler/grafana/api/v1/rules' \
    -H 'accept: application/json, text/plain, */*' \
    -H 'x-grafana-org-id: 1' \
    --insecure \
    --silent \
    -u $GF_SECURITY_ADMIN_USER:$GF_SECURITY_ADMIN_PASSWORD \
| jq .)

lenght=$(echo $rulefolders | jq -r '. | length')

if [ "$lenght" == "0" ]
then
    echo "no alert rules found"
else
    for folder in $(echo "${rulefolders}" | jq -r 'keys[] | @base64' ); do

        rules=$(echo $rulefolders | jq --arg folder "$(echo $folder | base64 -d)" -r '.[$folder]')
        
        for rule in $(echo "${rules}" | jq -r '.[] | @base64'); do
            _rule() {
                echo ${rule} | base64 -d | jq -r ${1}
            }
            
            rule=$(echo $(_rule '.') | jq -r '.name | @url')
            
            echo "delete alert rule '$(echo $folder | base64 -d)/$rule'"
            curl "http://grafana:3000/api/ruler/grafana/api/v1/rules/$(echo $folder | base64 -d)/${rule}" \
            -X 'DELETE' \
            -H 'accept: application/json, text/plain, */*' \
            -H 'x-grafana-org-id: 1' \
            --insecure \
            --silent \
            -u $GF_SECURITY_ADMIN_USER:$GF_SECURITY_ADMIN_PASSWORD \
            | jq .
            
        done
    done
fi

# create alert rules

rulefolders=$(cat $SCRIPT_DIR/alert-rules.json)

for folder in $(echo "${rulefolders}" | jq -r 'keys[]' ); do
    rules=$(echo $rulefolders | jq --arg folder "$folder" -r '.[$folder]')
    
    for rule in $(echo "${rules}" | jq -r '.[] | @base64'); do
        _rule() {
            echo ${rule} | base64 -d | jq -r ${1}
        }
        
        rulename=$(echo $(_rule '.') | jq -r '.name')

        echo "create alert rule '$folder/$rulename'"

        rule=$(echo $(_rule '.'))

        #echo $rule | jq .
        
        
        curl "http://grafana:3000/api/ruler/grafana/api/v1/rules/${folder}" \
        -H 'accept: application/json, text/plain, */*' \
        -H 'content-type: application/json' \
        -H 'x-grafana-org-id: 1' \
        --data-raw "$rule" \
        --insecure \
        --silent \
        -u $GF_SECURITY_ADMIN_USER:$GF_SECURITY_ADMIN_PASSWORD \
        | jq .
    done
done
