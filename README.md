# K6 benchmark visualization
* Adds visualization for K6 test in https://github.com/owncloud/cdperf.
* Internal docs only: https://confluence.owncloud.com/display/OT/K6+benchmark+visualization

## Add dashboards
You have to add the dasboards json to this folder `config/grafana/dashboards/load-testing` in order to make it persistent. Else it may disappear soon.

## Development
```
$ cp docker-compose.override.yml.dist docker-compose.override.yml
$ docker-compose up grafana
```

## Deployment
1. prepare a server + DNS entries
1. clone this repo and `cd` into it
1. copy configuration file `cp .env.dist .env`
1. edit configuration files according your needs
1. run `docker-compose up -d`
