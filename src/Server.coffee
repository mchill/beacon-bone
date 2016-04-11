winston = require('winston')
express = require('express')
app = require('express')()
server = require('http').createServer(app)
io = require('socket.io')(server)
mqtt = require('mqtt')
Vector = require('victor')
Map = require('./Map.coffee').Map
TrackedItem = require('./TrackedItem.coffee').TrackedItem

# Streams a continuously updated image of the map of the indoor
# environment and the publishing objects within it to clients
# over and HTTP connection.
#
class exports.Server
    # Instantiates a server to display the map to users over HTTP.
    # Connects to the broker and prepares the map.
    #
    # brokerIP
    #         the IP address of the MQTT broker
    #
    constructor: (@brokerIP) ->
        @trackedItems = {}
        @map = new Map()

        itemMap = {
            "1": "54:4a:16:e6:90:09",
            "2": "",
            "3": "78:a5:04:c8:a0:e4",
            "4": "f0:1f:af:1f:3c:18"
        }

        winston.verbose("Connecting to the MQTT broker at #{@brokerIP}")
        @client = mqtt.connect(@brokerIP)

        app.get('/', (req, res) =>
            @trackedItems = {}
            @clientId = itemMap[req.query.client]
            @targetId = itemMap[req.query.target]

            winston.verbose('Serving index.html to a client')
            res.sendFile('public/index.html', {'root': "#{__dirname}/../"})
        )

    # Start listening over port 80 on the HTTP server.
    # Subscribe to all positions on the broker and declare what
    # to do on MQTT messages. Set timing for redrawing the map.
    #
    start: =>
        server.listen(80, =>
            winston.info('HTTP server started')
        )

        @client.on('connect', =>
            winston.info("Connected to the MQTT broker at #{@brokerIP}")
            @client.subscribe('position/#')
        )

        @client.on('message', @processMessage)

        io.on('connection', (socket) =>
            winston.info('Connected to a client over a socket')
            @socket = socket
            setInterval(@drawMap, 500)
        )

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
    drawMap: =>
        winston.verbose('Sending image to client')
        @socket.emit('messages', @map.getCanvas(@trackedItems).toDataURL())

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
            @trackedItems[index] = new TrackedItem(index, position)

            if index == @clientId
                @trackedItems[index].setClient()
            else if index == @targetId
                @trackedItems[index].setTarget()

            return

        @trackedItems[index].updatePosition(position)
