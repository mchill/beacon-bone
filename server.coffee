app = require('express')()
server = require('http').createServer(app)
io = require('socket.io')(server)
winston = require('winston')
Server = require('./src/Server.coffee').Server
Client = require('./src/Client.coffee').Client

winston.remove(winston.transports.Console);
winston.add(winston.transports.File, {filename: 'logs/server.log', level: 'info'})
winston.add(winston.transports.Console, {level: 'verbose'});

ip = process.argv[2]
if !ip?
    winston.error 'Usage: coffee server.coffee brokerIP'
    process.exit 1

myServer = new Server(ip, server)
clients = []
sockets = []

app.get('/', (req, res) =>
    client = new Client(server, myServer, req.query.client, req.query.target)
    clients.push(client)

    winston.verbose('Serving index.html to a client')
    res.sendFile("#{__dirname}/public/index.html")
)

io.on('connection', (socket) =>
    winston.info('Connected to a client over a socket')
    sockets.push(socket)
)

server.listen(80, =>
    winston.info('HTTP server started')
)

setInterval(( =>
        if sockets.length == 0 or clients.length == 0
            return

        clients[clients.length-1].addSocket(sockets[sockets.length-1])
        sockets.pop()
    ), 100)
