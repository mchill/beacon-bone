winston = require('winston')
NodeBeacon = require('bleacon')
mqtt = require('mqtt')
getmac = require('getmac')
Vector = require('victor')
Beacon = require('./Beacon.coffee').Beacon

# Handles publishing position to the MQTT server.
#
class exports.Publisher
    # Instantiates a publisher with an empty list of registered
    # beacons and an MQTT connection. Also finds the BBBK's
    # MAC address to use as an MQTT identifier.
    #
    # brokerIP
    #         the IP address of the MQTT broker
    #
    constructor: (@brokerIP) ->
        @beacons = {}
        @position = null

        winston.verbose("Connecting to the MQTT broker at #{@brokerIP}")
        @client = mqtt.connect(@brokerIP)

        getmac.getMac((err, macAddress) =>
            if err?
                winston.error('MAC address cannot be read')
                process.exit 1

            winston.info("MAC address recorded: #{macAddress}")
            @macAddress = macAddress
        )

        NodeBeacon.on('discover', @registerBeacon)

    # Begin scanning for beacons and publishing to the broker.
    #
    start: =>
        @client.on('connect', =>
            winston.info("Connected to the MQTT broker at #{@brokerIP}")
            setInterval(@publish, 500)
        )

        setInterval(@purgeBeacons, 500)
        setInterval(@getPosition, 500)

        winston.info('Start scanning for beacons')
        NodeBeacon.startScanning('00000000000000000000000000000000')

    # Publish the user's position to the MQTT server under
    # the BBBK's MAC address.
    #
    publish: =>
        if @position?
            winston.verbose("Publishing position: #{@position.x},#{@position.y}")
            @client.publish("position/#{@macAddress}", "#{@position.x},#{@position.y}")

    # Add the beacon to the list of beacons if it does not already exist.
    # Then adds the latest distance to the beacon.
    #
    # data
    #     the data gathered from the beacon's PDU
    #
    registerBeacon: (data) =>
        time = new Date().getTime()

        index = data.major + ',' + data.minor
        position = new Vector(data.major, data.minor)
        beacon = @beacons[index]

        if !beacon?
            winston.info("New beacon #{index} discovered")
            beacon = new Beacon(position, data.measuredPower)
            @beacons[index] = beacon

        beacon.addDistance(data.rssi, time)

    # Remove beacons with no recent calculated distances from the
    # list of active beacons.
    #
    purgeBeacons: =>
        for index, beacon of @beacons
            if !beacon.isActive()
                winston.info("Beacon #{index} no longer in range")
                delete @beacons[index]

    # Find the position of the user in the map using the calculated
    # distances from each beacon. Uses at most the closest two beacons.
    #
    # If one beacon is present, that beacon's position is used.
    # if two beacons are present, a position between those beacons
    # is chosen proportional to the two calculated distances.
    #
    getPosition: =>
        first = null
        second = null

        for index, beacon of @beacons
            if beacon.isActive()
                if !first?
                    first = beacon
                else if beacon.getDistance() < first.getDistance()
                    second = first
                    first = beacon;
                else if !second?
                    second = beacon
                else if beacon.getDistance() < second.getDistance()
                    second = beacon

        if first? and second?
            diffX = second.getPosition().x - first.getPosition().x
            diffY = second.getPosition().y - first.getPosition().y

            proportion = first.getDistance() / (first.getDistance() + second.getDistance())

            @position = new Vector(first.getPosition().x + proportion * diffX,
                first.getPosition().y + proportion * diffY)

        else if first?
            @position = first.getPosition().clone()

        else
            @position = null
