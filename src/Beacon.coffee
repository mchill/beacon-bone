# Represents a beacon in the environment.
#
class exports.Beacon
    # A list of distances calculated over time
    distances = []

    # Instantiates the beacon with some defining information.
    #
    # x
    #  the horizontal position inn the map
    # y
    #  the vertical position in the map
    # measuredPower
    #              the advertised RSSI at a distance of 1 meter
    #
    constructor: (@x, @y, @measuredPower) ->

    # Gets the average distance from the detecting system over a set
    # period of time.
    #
    # returns the average distance over the 2 seconds
    #
    getDistance: ->
        return distances.reduce((t, s) -> t + s) / distances.length

    # Calculate and add a distance to the list of distances.
    #
    # rssi
    #     the measured RSSI (received signal strength indication)
    #
    addDistance: (rssi) ->
        distances.push(Math.pow(10, (@measuredPower - rssi) / 20))
