Server = require('./src/Server.coffee').Server

ip = process.argv[2]
if !ip?
    throw new Error('Usage: coffee server.coffee brokerIP')

server = new Server(ip)
server.start()
