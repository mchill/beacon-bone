Publisher = require('./src/Publisher.coffee').Publisher

ip = process.argv[2]
if !ip?
    throw new Error('Usage: coffee publisher.coffee brokerIP')
publisher = new Publisher(ip)
