winston = require('winston')

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
        setInterval(@calcAvgDistance, 500)
        setInterval(@purgeDistances, 500)

    # Return the x position of the beacon.
    #
    getX: =>
        return @x

    # Return the y position of the beacon.
    #
    getY: =>
        return @y

    # Returns the average distance away over time.
    #
    getDistance: =>
        if !@avgDistance?
            @calcAvgDistance()
        if !@avgDistance?
            winston.error("Average distance requested for inactive beacon #{@x},#{@y}")
            process.exit 1

        return @avgDistance

    # Calculate and add a distance to the list of distances.
    #
    # rssi
    #     the measured RSSI (received signal strength indication)
    # time
    #     the time when the beacon was discovered
    #
    addDistance: (rssi, time) =>
        distance = 0.7 * Math.pow(rssi * 1.0 / @measuredPower, 6) + 0.3
        @distances[time] = distance
        winston.verbose("Distance #{distance} added to beacon #{@x},#{@y}")

    # Calculates the average distance from the detecting system.
    #
    calcAvgDistance: =>
        distanceList = (distance for time, distance of @distances)
        if distanceList.length != 0
            distance = distanceList.reduce((first, second) -> first + second) / distanceList.length
            @avgDistance = distance
            winston.verbose("Average distance #{distance} calculated for beacon #{@x},#{@y}")

    # Removes old distances from the list of distances.
    # Since the list is ordered, stop once a valid time is found.
    #
    purgeDistances: =>
        time = new Date().getTime()

        for milliseconds, distance of @distances
            if milliseconds < time - 2000
                delete @distances[milliseconds]
                continue
            break

    # Indicates whether any distances are registered with this beacon.
    #
    # return true if at least one distance, false if none
    #
    isActive: =>
        if Object.keys(@distances).length is 0
            return false
        return true
