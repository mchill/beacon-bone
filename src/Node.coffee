Vector = require('victor')

# Represents a node in the path of the indoor environment.
#
class exports.Node
    constructor: (@position) ->
        @edges = {}
        @lastTraversed = null
        @csf = 0

    getPosition: =>
        return @position

    addEdge: (node, csf) =>
        @position[csf] = node

    setLastTraversed: (lastTraversed) =>
        @lastTraversed = lastTraversed

    setCSF: (csf) =>
        @csf = csf
