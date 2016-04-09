Vector = require('victor')

# Represents a node in the path of the indoor environment.
#
class exports.Node
    # Instantiates a node with its represented region
    # and some pathfinding metadata.
    #
    # position
    #         the coordinates of the upper-left corner of the region
    # dimensions
    #           the width and height of the region
    #
    constructor: (@position, @dimensions) ->
        @edges = {}
        @lastTraversed = null
        @csf = 0

    # Connect another node to this node.
    #
    # node
    #     the node to connect
    # cost
    #     the cost to that node
    #
    addEdge: (node, cost) =>
        @edges[cost] = node

    # Set the last node traversed in the shortest path.
    #
    # lastTraversed
    #              the node that was traversed last
    #
    setLastTraversed: (lastTraversed) =>
        @lastTraversed = lastTraversed

    # Set the cost so far in the shortest path.
    #
    # csf
    #    cost so far
    #
    setCSF: (csf) =>
        @csf = csf
