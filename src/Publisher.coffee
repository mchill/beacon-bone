NodeBeacon = require('bleacon')
Beacon = require('./Beacon.coffee').Beacon
mqtt = require('mqtt')
getmac = require('getmac')

# Handles publishing position to the MQTT server.
#
class exports.Publisher
    # Instantiates a publisher with an empty list of registered
    # beacons and an MQTT connection. Also sets up the timing
    # for helper methods to be called.
    #
    # brokerIP
    #         the IP address of the MQTT broker
    #
    constructor: (brokerIP) ->
        @beacons = {}
        @client = mqtt.connect(brokerIP)

        setInterval(@publish, 500)
        setInterval(@purgeBeacons, 500)

        NodeBeacon.on('discover', @registerBeacon)
        NodeBeacon.startScanning('00000000000000000000000000000000')

    # Publish the user's position to the MQTT server under
    # the BBBK's MAC address.
    #
    publish: =>
        getmac.getMac (err, macAddress) =>
            if err?
                console.log 'Error: MAC Address cannot be read'

            @client.publish('position/' + macAddress, 'Hello mqtt')

    # Add the beacon to the list of beacons if it does not already exist.
    # Then adds the latest distance to the beacon.
    #
    # data
    #     the data gathered from the beacon's PDU
    #
    registerBeacon: (data) =>
        time = new Date().getTime()

        index = data.major + ',' + data.minor
        beacon = @beacons[index]

        if !beacon?
            beacon = new Beacon(data.major, data.minor, data.measuredPower)
            @beacons[index] = beacon

        beacon.addDistance(data.rssi, time)

    # Remove beacons with no recent calculated distances from the
    # list of active beacons.
    #
    purgeBeacons: =>
        for index, beacon of @beacons
            if !beacon.isActive()
                delete @beacons[index]
