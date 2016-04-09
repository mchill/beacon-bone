Vector = require('victor')

# Represents a node in the path of the indoor environment.
#
class exports.Node
    # Instantiates a node with its represented region
    # and some pathfinding metadata.
    #
    # region
    #       the region represented by the node,
    #           represented as ((p_x, p_y), (width, height))
    # path
    #     the line that an item can visually move through the region,
    #         represented as ((p1_x, p1_y), (p2_x, p2_y))
    #
    constructor: (@region, @path) ->
        @edges = {}
        @lastTraversed = null
        @csf = 0

    # Return the region represented by the node.
    #
    getRegion: =>
        return @region

    # Return the path that an item can visually travel in the region.
    #
    getPath: =>
        return @path

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
