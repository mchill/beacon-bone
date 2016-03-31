# Represents a beacon in the environment.
#
class exports.Beacon
    # Instantiates the beacon with some defining information
    # and an empty list of calculated distances.
    #
    # x
    #  the horizontal position inn the map
    # y
    #  the vertical position in the map
    # measuredPower
    #              the advertised RSSI at a distance of 1 meter
    #
    constructor: (@x, @y, @measuredPower) ->
        @distances = {}
        setInterval(@purgeDistances, 500)

    # Gets the average distance from the detecting system over a set
    # period of time.
    #
    # returns the average distance over the some period of time
    #
    getDistance: ->
        distanceList = (distance for time, distance of @distances)
        return distanceList.reduce((first, second) -> first + second) / distanceList.length

    # Calculate and add a distance to the list of distances.
    #
    # rssi
    #     the measured RSSI (received signal strength indication)
    # time
    #     the time when the beacon was discovered
    #
    addDistance: (rssi, time) ->
        @distances[time] = Math.pow(10, (@measuredPower - rssi) / 20)
        console.log(@getDistance())

    # Removes old distances from the list of distances.
    # Since the list is ordered, stop once a valid time is found.
    #
    purgeDistances: =>
        time = new Date().getTime()

        for milliseconds, distance of @distances
            if milliseconds < time - 1000
                delete @distances[milliseconds]
                continue
            break

    # Indicates whether any distances are registered with this beacon.
    #
    # return true if at least one distance, false if none
    #
    isActive: ->
        if Object.keys(@distances).length is 0
            return false
        return true
