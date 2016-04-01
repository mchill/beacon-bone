winston = require('winston')
Publisher = require('./src/Publisher.coffee').Publisher

winston.remove(winston.transports.Console);
winston.add(winston.transports.File, {filename: 'logs/publisher.log', level: 'info'})
winston.add(winston.transports.Console, {level: 'verbose'});

ip = process.argv[2]
if !ip?
    winston.error 'Usage: coffee publisher.coffee brokerIP'
    process.exit 1

publisher = new Publisher(ip)
publisher.start()
