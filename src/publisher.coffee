NodeBeacon = require('bleacon')
Beacon = require('./Beacon.coffee').Beacon
mqtt = require('mqtt')

# Begin with an empty list of active beacons
beacons = {}

# Get server IP from command-line argument
ip = process.argv[2]
if !ip?
    throw new Error('Usage: npm run-script publisher serverIP')

# Connect to server
client = mqtt.connect(ip)

# Publish to the server every half second
setInterval( ->
    client.publish('beaconbone', 'Hello mqtt')
, 500)

# Scan for beacons with the UUID 0
NodeBeacon.startScanning('00000000000000000000000000000000')

# Purge old distances every half second
setInterval( ->
    # Remove distances older than one second
    time = new Date().getTime() - 1000

    # Iterate through beacons
    for index, beacon of beacons
        # Purge the beacon's distances
        beacon.purgeDistances(time)

        # If the beacon no longer has any registered distances
        if !beacon.isActive()
            # Remove the beacon from the list
            delete beacons[index]
, 500)

# Called when a beacon is detected
NodeBeacon.on('discover', (data) ->
    # Capture the time at which the beacon is discovered
    time = new Date().getTime()

    # Beacons are indexed in the associative array as their major,minor
    index = data.major + ',' + data.minor
    beacon = beacons[index]

    # If the beacon was not already active
    if !beacon?
        # Create it and add it to the list
        beacon = new Beacon(data.major, data.minor, data.measuredPower)
        beacons[index] = beacon

    # Add the newest distance
    beacon.addDistance(data.rssi, time)

    # Print the average distance
    console.log(beacon.getDistance())
)
