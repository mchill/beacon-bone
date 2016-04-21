app = require('express')()
server = require('http').createServer(app)
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

app.get('/', (req, res) =>
    client = new Client(server, myServer, req.query.client, req.query.target)

    winston.verbose('Serving index.html to a client')
    res.sendFile("#{__dirname}/public/index.html")
)

server.listen(80, =>
    winston.info('HTTP server started')
)
