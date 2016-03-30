app = require('express')()
server = require('http').createServer(app)
io = require('socket.io')(server)

Canvas = require('canvas')
canvas = new Canvas(200, 200)
context = canvas.getContext('2d')

# On connection with a client, set drawMap to run twice per second
io.on 'connection', (client) ->
    setInterval( ->
        drawMap(client)
    , 500)

# Draws the map based on current data and sends it to the client.
#
# client
#       the socket connected to the client
drawMap = (client) ->
    context.clearRect(0, 0, canvas.width, canvas.height);

    # TODO: draw map

    client.emit('messages', canvas.toDataURL())

# Serve index.html
app.get '/', (req, res) ->
    res.sendFile(__dirname + '/index.html')

# Listen on port 80
server.listen 80, ->
    console.log 'Success: server started'
