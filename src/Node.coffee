Vector = require('victor')

# Represents a node in the path of the indoor environment.
#
class exports.Node
    constructor: (x, y) ->
        @edges = {}
        @lastTraversed = null
        @csf = 0

        @position = new Vector(x, y)

    getPosition: =>
        return @position

    addEdge: (node, csf) =>
        @position[csf] = node

    setLastTraversed: (lastTraversed) =>
        @lastTraversed = lastTraversed

    setCSF: (csf) =>
        @csf = csf
