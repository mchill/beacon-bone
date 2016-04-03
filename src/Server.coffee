winston = require('winston')
express = require('express')
app = require('express')()
server = require('http').createServer(app)
io = require('socket.io')(server)
Canvas = require('canvas')
mqtt = require('mqtt')

# Streams a continuously updated image of the map of the indoor
# environment and the publishing objects within it to clients
# over and HTTP connection.
#
class exports.Server
    # Instantiates a server to display the map to users over HTTP.
    # Connects to the broker and prepares the canvas.
    #
    # brokerIP
    #         the IP address of the MQTT broker
    #
    constructor: (@brokerIP) ->
        winston.verbose("Connecting to the MQTT broker at #{@brokerIP}")
        @client = mqtt.connect(@brokerIP)

        @canvas = new Canvas(200, 200)
        @context = @canvas.getContext('2d')

        app.get('/', (req, res) =>
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

    # Draws the map based on current data and sends it using the socket.
    #
    drawMap: =>
        @context.clearRect(0, 0, @canvas.width, @canvas.height);

        # TODO: draw map

        winston.verbose('Sending image to client')
        @socket.emit('messages', @canvas.toDataURL())

    # Process an MQTT message.
    #
    processMessage: (topic, message) =>
        # TODO: process topics to draw objects on the canvas
        winston.verbose("MQTT message from topic #{topic}: " + message.toString())
