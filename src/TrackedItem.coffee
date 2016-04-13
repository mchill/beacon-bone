Vector = require('victor')

# Represents any item publishing its position to the MQTT broker,
# and therefore being tracked by the HTTP server.
#
class exports.TrackedItem
    # Instantiates a tracked item for the HTTP server to keep track of.
    #
    # id
    #   the MAC address (or some other identification) of the tracked item
    # position
    #         a vector representing the position of the item in the environment
    #
    constructor: (@id, position, @graph) ->
        @updatePosition(position)

    # Returns the position of the item.
    #
    getPosition: =>
        return @position

    # Returns the node representing the region that the tracked item is in.
    getNode: =>
        return @node

    # Returns true if this item is the one that the client is tracking.
    #
    isClient: =>
        return @client?

    # Returns true if this item is the one that the client is finding.
    #
    isTarget: =>
        return @target?

    # Return the time at which the position was last updated
    #
    lastPublished: =>
        return @time

    # Updates the position of the tracked item with the newest published value.
    #
    # position
    #         a vector representing the position of the item in the environment
    #
    updatePosition: (position) =>
        @position = position
        for node in @graph
            if node.isInRegion(position)
                @node = node

        @time = new Date().getTime()

    # Define this item as the one that the client is tracking.
    #
    setClient: =>
        @client = true

    # Define this item as the one that the client is finding.
    #
    setTarget: =>
        @target = true
