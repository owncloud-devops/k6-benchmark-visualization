# K6 benchmark visualization

Adds visualization for K6 test in https://github.com/owncloud/ocis/tree/master/tests/k6.

## Add dashboards
You have to add the dasboards json to this folder `config/grafana/dashboards/load-testing` in order to make it persistent. Else it may disappear soon.

## Deployment

1. prepare a server + DNS entries
1. clone this repo and `cd` into it
1. copy configuration file `cp .env.dist .env`
1. edit configuration files according your needs
1. run `docker-compose up -d`
