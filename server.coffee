winston = require('winston')
Server = require('./src/Server.coffee').Server

winston.remove(winston.transports.Console);
winston.add(winston.transports.File, {filename: 'server.log', level: 'info'})
winston.add(winston.transports.Console, {level: 'verbose'});

ip = process.argv[2]
if !ip?
    winston.error 'Usage: coffee server.coffee brokerIP'
    process.exit 1

server = new Server(ip)
server.start()
