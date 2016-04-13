Canvas = require('canvas')
Vector = require('victor')
Node = require('./Node.coffee').Node
TrackedItem = require('./TrackedItem.coffee').TrackedItem

# Represents the indoor environment. Used for both pathfinding
# and visualization on the web page.
#
class exports.Map
    # Instantiates the map with data about the nodes, regions,
    # and canvas objects that represent it.
    #
    constructor: ->
        @scale = 20
        @constructGraph()
        @drawBackground()

    # Populates the graph with a collection of nodes defined by
    # the regions in the environment that they represent. Connect
    # the appropriate nodes with edges.
    #
    constructGraph: =>
        @graph = [
            new Node(new Vector(new Vector(23, 9), new Vector(8, 7)),
                new Vector(new Vector(27, 9), new Vector(27, 16))),
            new Node(new Vector(new Vector(23, 1), new Vector(8, 3)),
                new Vector(new Vector(27, 4), new Vector(27, 9))),
            new Node(new Vector(new Vector(23, 4), new Vector(8, 5)),
                new Vector(new Vector(23, 2.5), new Vector(27, 4))),
            new Node(new Vector(new Vector(16, 1), new Vector(7, 3)),
                new Vector(new Vector(16, 2.5), new Vector(23, 2.5))),
            new Node(new Vector(new Vector(10, 1), new Vector(6, 3)),
                new Vector(new Vector(10, 2.5), new Vector(16, 2.5))),
            new Node(new Vector(new Vector(8, 1), new Vector(2, 3)),
                new Vector(new Vector(9, 4), new Vector(10, 2.5))),
            new Node(new Vector(new Vector(8, 4), new Vector(2, 7)),
                new Vector(new Vector(9, 11), new Vector(9, 4))),
            new Node(new Vector(new Vector(8, 11), new Vector(2, 5)),
                new Vector(new Vector(9, 16), new Vector(9, 11))),
            new Node(new Vector(new Vector(8, 16), new Vector(2, 3)),
                new Vector(new Vector(9, 19), new Vector(9, 16))),
            new Node(new Vector(new Vector(8, 19), new Vector(2, 3)),
                new Vector(new Vector(9, 22), new Vector(9, 19))),
            new Node(new Vector(new Vector(1, 11), new Vector(7, 5)),
                new Vector(new Vector(1, 13.5), new Vector(8, 13.5))),
            new Node(new Vector(new Vector(1, 17), new Vector(7, 2)),
                new Vector(new Vector(1, 18), new Vector(8, 18)))
        ]

        @graph[0].addEdge(@graph[1], 1)
        @graph[1].addEdge(@graph[0], 1)
        @graph[1].addEdge(@graph[2], 1)
        @graph[2].addEdge(@graph[1], 1)
        @graph[2].addEdge(@graph[3], 1)
        @graph[3].addEdge(@graph[2], 1)
        @graph[3].addEdge(@graph[4], 1)
        @graph[4].addEdge(@graph[3], 1)
        @graph[4].addEdge(@graph[5], 1)
        @graph[5].addEdge(@graph[4], 1)
        @graph[5].addEdge(@graph[6], 1)
        @graph[6].addEdge(@graph[5], 1)
        @graph[6].addEdge(@graph[7], 1)
        @graph[7].addEdge(@graph[6], 1)
        @graph[7].addEdge(@graph[8], 1)
        @graph[7].addEdge(@graph[10], 1)
        @graph[8].addEdge(@graph[7], 1)
        @graph[8].addEdge(@graph[9], 1)
        @graph[8].addEdge(@graph[11], 1)
        @graph[9].addEdge(@graph[8], 1)
        @graph[10].addEdge(@graph[7], 1)
        @graph[11].addEdge(@graph[8], 1)

    # Draw the hallways and beacons on the background canvas.
    #
    drawBackground: =>
        @beacons = [
            new Vector(1, 14),
            new Vector(1, 18),
            new Vector(8, 2),
            new Vector(9, 22),
            new Vector(10, 14),
            new Vector(10, 18),
            new Vector(18, 1),
            new Vector(27, 1),
            new Vector(27, 16),
            new Vector(31, 8)
        ]

        @background = new Canvas(32 * @scale, 23 * @scale)
        context = @background.getContext('2d')

        context.fillStyle = "#000000"
        context.fillRect(0, 0, @background.width, @background.height)

        context.fillStyle = "#FFFFFF"
        context.fillRect(1 * @scale, 11 * @scale, 7 * @scale, 5 * @scale)
        context.fillRect(1 * @scale, 17 * @scale, 7 * @scale, 2 * @scale)
        context.fillRect(8 * @scale, 1 * @scale, 2 * @scale, 21 * @scale)
        context.fillRect(10 * @scale, 1 * @scale, 13 * @scale, 3 * @scale)
        context.fillRect(23 * @scale, 1 * @scale, 8 * @scale, 15 * @scale)

        context.fillStyle = "#00FFFF"
        for beacon in @beacons
            context.beginPath()
            context.arc(beacon.x * @scale, beacon.y * @scale, @scale / 2, 0, 2 * Math.PI)
            context.fill()
            context.closePath()

    # Draws the tracked items over the background of the map and returns the canvas.
    #
    # trackedItems
    #             a list of items that are currently publishing position to the broker
    #
    getCanvas: (trackedItems) =>
        foreground = new Canvas(32 * @scale, 23 * @scale)
        context = foreground.getContext('2d')
        context.drawImage(@background, 0, 0)

        for index, trackedItem of trackedItems
            context.fillStyle = "#0000FF"

            if trackedItem.isClient()
                context.fillStyle = "#00FF00"
            else if trackedItem.isTarget()
                context.fillStyle = "#FF0000"

            position = trackedItem.getPosition()

            context.beginPath()
            context.arc(position.x * @scale, position.y * @scale, @scale / 2, 0, 2 * Math.PI)
            context.fill()
            context.closePath()

        return foreground

    # Implements Dijkstra's Algorithm to determine the shortest path to a destination
    #
    # srcTrackedItem
    #               The client item where pathfinding will begin
    #
    # destTrackedItem
    #                The target item where pathfinding will end
    findPath: (srcTrackedItem, destTrackedItem) =>
        idx = 0
        foundPath = {}
        known = {}

        for index, Node of graph
            if Node.atNode(srcTrackedItem.getPosition().x, srcTrackedItem.getPosition().y)
                known[idx] = Node
                foundPath[idx] = Node

        while idx < 11
            for index, Node of known[idx].getEdges()
                Node.setLastTraversed(known[idx])
                Node.setCSF(Node.getLastTraversed.getCSF()

            if foundPath[idx-1].atNode(destTrackedItem.getPosition().x, destTrackedItem.getPosition().y)
                return foundPath