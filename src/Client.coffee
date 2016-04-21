winston = require('winston')

# Streams a continuously updated image of the map of the indoor
# environment and the publishing objects within it to clients
# over and HTTP connection.
#
class exports.Client
    constructor: (server, @myServer, client, target) ->
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

        setInterval(@drawMap, 500)

    # Adds a socket for the server to send the client updated map images.
    # Returns false if the socket is already set, and true if not.
    #
    # socket
    #       the socket for this client
    #
    addSocket: (socket) =>
        @socket = socket

    # Draws the map based on current data and sends it using the socket.
    #
    drawMap: =>
        if @socket?
            winston.verbose('Sending image to client')
            console.log @socket.id
            @socket.emit('messages', @myServer.drawMap(@clientId, @targetId))
