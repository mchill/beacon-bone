winston = require('winston')

# Streams a continuously updated image of the map of the indoor
# environment and the publishing objects within it to clients
# over and HTTP connection.
#
class exports.Client
    constructor: (server, @myServer, client, target) ->
        @io = require('socket.io')(server)

        @io.on('connection', (socket) =>
            winston.info('Connected to a client over a socket')
            @socket = socket
            setInterval(@drawMap, 500)
        )

        itemMap = {
            "1": "54:4a:16:e6:90:09",
            "2": "6c:ec:eb:a4:c9:d8",
            "3": "78:a5:04:c8:a0:e4",
            "4": "f0:1f:af:1f:3c:18"
        }

        @clientId = itemMap[client]
        @targetId = itemMap[target]

        if !@clientId? then @clientId = client
        if !@targetId? then @targetId = target

    # Draws the map based on current data and sends it using the socket.
    #
    drawMap: =>
        winston.verbose('Sending image to client')
        @socket.emit('messages', @myServer.drawMap(@clientId, @targetId))
