# BeaconBone

## Install

1. `git clone git@github.ncsu.edu:vtduong/BeaconBone.git`
2. `cd BeaconBone`
3. `./setup.sh`
4. `npm install`

## Run

### Publishing

`coffee publisher.coffee brokerIP`

### MQTT Broker

`mosca -v | bunyan`

### HTTP Server

`coffee server.coffee brokerIP`
