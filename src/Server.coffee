winston = require('winston')
express = require('express')
mqtt = require('mqtt')
Vector = require('victor')
Map = require('./Map.coffee').Map
TrackedItem = require('./TrackedItem.coffee').TrackedItem

# Keeps track of the indoor environment in a single place,
# and lets clients use that one knowledge source to create
# paths for different targets.
#
class exports.Server
    # Instantiates a server to display the map to users over HTTP.
    # Connects to the broker and prepares the map.
    #
    # brokerIP
    #         the IP address of the MQTT broker
    # server
    #       the express server
    #
    constructor: (@brokerIP, @server) ->
        @trackedItems = {}
        @map = new Map()

        winston.verbose("Connecting to the MQTT broker at #{@brokerIP}")
        @client = mqtt.connect(@brokerIP)

        @trackedItems = {}

        @client.on('connect', =>
            winston.info("Connected to the MQTT broker at #{@brokerIP}")
            @client.subscribe('position/#')
        )

        @client.on('message', @processMessage)

        setInterval(@purgeTrackedItems, 500)
        
    # Removed tracked items that have not published a position recently.
    #
    purgeTrackedItems: =>
        time = new Date().getTime()

        for index, trackedItem of @trackedItems
            if trackedItem.lastPublished() < time - 2000
                winston.info("Item #{index} no longer being tracked")
                delete @trackedItems[index]

    # Draws the map based on current data and sends it using the socket.
    #
    # clientId
    #         the MAC address of the client
    # targetId
    #         the MAC address of the target
    #
    drawMap: (clientId, targetId) =>
        return @map.getCanvas(@trackedItems, clientId, targetId).toDataURL()

    # Process an MQTT message. Either adds a tracked item to the list
    # if it does not exist, or updates the item's position if it does.
    #
    # topic
    #      specifies which BeagleBone published the position
    # message
    #        contains the position in the format x,y
    #
    processMessage: (topic, message) =>
        winston.verbose("MQTT message from topic #{topic}: " + message.toString())

        positionString = message.toString().split(",")
        position = new Vector(positionString[0], positionString[1])

        index = topic.split("/")[1]
        trackedItem = @trackedItems[index]

        if !trackedItem?
            winston.info("New item #{index} being tracked")
            @trackedItems[index] = new TrackedItem(index, position, @map.getGraph())
            return

        @trackedItems[index].updatePosition(position)
