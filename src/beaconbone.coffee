# Require the bleacon library and Beacon class
NodeBeacon = require('bleacon')
Beacon = require('./Beacon.coffee').Beacon

# Begin with an empty list of active beacons
beacons = {}

# Scan for beacons
NodeBeacon.startScanning()

# Called when a beacon is detected
NodeBeacon.on('discover', (data) ->
    # Get the UUID of the beacon as a hex integer
    uuid = parseInt(data.uuid, 16)

    # Beacons specific to the BeaconBone project have a UUID of 0
    if uuid is 0
        # Beacons are indexed in the associative array as their major,minor
        index = data.major + ',' + data.minor
        beacon = beacons[index]

        # If the beacon was not already active
        if !beacon?
            # Create it and add it to the list
            beacon = new Beacon(data.major, data.minor, data.measuredPower)
            beacons[index] = beacon

        # Add the newest distance
        beacon.addDistance(data.rssi)

        # Print the average distance
        console.log(beacon.getDistance())
)
