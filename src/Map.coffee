Canvas = require('canvas')
Vector = require('victor')
winston = require('winston')
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

    # Return the list of nodes in the map's graph.
    #
    getGraph: =>
        return @graph

    # Populates the graph with a collection of nodes defined by
    # the regions in the environment that they represent. Connect
    # the appropriate nodes with edges.
    #
    constructGraph: =>
        @graph = [
            new Node(new Vector(new Vector(23, 9), new Vector(8, 7)),
                new Vector(new Vector(27, 9), new Vector(27, 16))),
            new Node(new Vector(new Vector(23, 4), new Vector(8, 5)),
                new Vector(new Vector(27, 4), new Vector(27, 9))),
            new Node(new Vector(new Vector(23, 1), new Vector(8, 3)),
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

        @graph[0].addEdge(@graph[1], 6)
        @graph[1].addEdge(@graph[0], 6)
        @graph[1].addEdge(@graph[2], 4)
        @graph[2].addEdge(@graph[1], 4)
        @graph[2].addEdge(@graph[3], 3)
        @graph[3].addEdge(@graph[2], 3)
        @graph[3].addEdge(@graph[4], 4)
        @graph[4].addEdge(@graph[3], 4)
        @graph[4].addEdge(@graph[5], 3)
        @graph[5].addEdge(@graph[4], 3)
        @graph[5].addEdge(@graph[6], 4)
        @graph[6].addEdge(@graph[5], 4)
        @graph[6].addEdge(@graph[7], 5)
        @graph[7].addEdge(@graph[6], 5)
        @graph[7].addEdge(@graph[8], 3)
        @graph[7].addEdge(@graph[10], 1)
        @graph[8].addEdge(@graph[7], 3)
        @graph[8].addEdge(@graph[9], 2)
        @graph[8].addEdge(@graph[11], 1)
        @graph[9].addEdge(@graph[8], 2)
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

        context.fillStyle = '#000000'
        context.fillRect(0, 0, @background.width, @background.height)

        context.fillStyle = '#FFFFFF'
        context.fillRect(1 * @scale, 11 * @scale, 7 * @scale, 5 * @scale)
        context.fillRect(1 * @scale, 17 * @scale, 7 * @scale, 2 * @scale)
        context.fillRect(8 * @scale, 1 * @scale, 2 * @scale, 21 * @scale)
        context.fillRect(10 * @scale, 1 * @scale, 13 * @scale, 3 * @scale)
        context.fillRect(23 * @scale, 1 * @scale, 8 * @scale, 15 * @scale)

        context.fillStyle = '#00FFFF'
        for beacon in @beacons
            context.beginPath()
            context.arc(beacon.x * @scale, beacon.y * @scale, @scale / 2, 0, 2 * Math.PI)
            context.fill()
            context.closePath()

    # Draws the tracked items over the background of the map and returns the canvas.
    #
    # trackedItems
    #             a list of items that are currently publishing position to the broker
    # clientId
    #         the MAC address of the client
    # targetId
    #         the MAC address of the target
    #
    getCanvas: (trackedItems, clientId, targetId) =>
        foreground = new Canvas(32 * @scale, 23 * @scale)
        context = foreground.getContext('2d')
        context.drawImage(@background, 0, 0)

        for index, trackedItem of trackedItems
            context.fillStyle = '#0000FF'

            id = trackedItem.getId()
            if id == clientId
                context.fillStyle = '#00FF00'
                client = trackedItem
            else if id == targetId
                context.fillStyle = '#FF0000'
                target = trackedItem

            position = trackedItem.getPosition()
            node = trackedItem.getNode()
            if !node?
                continue

            path = node.getPath()
            position = @getClosestPoint(path.x, path.y, position)

            if id == clientId
                region = node.getRegion()
                context.strokeStyle = '#00FF00'
                context.strokeRect(region.x.x * @scale, region.x.y * @scale, region.y.x * @scale, region.y.y * @scale)

            context.beginPath()
            context.arc(position.x * @scale, position.y * @scale, @scale / 2, 0, 2 * Math.PI)
            context.fill()
            context.closePath()

        if client?
            clientNode = client.getNode()
        else if clientId?
            clientId = parseInt(clientId.substring(4), 10)
            clientNode = @graph[clientId]
        if target?
            targetNode = target.getNode()
        else if targetId?
            targetId = parseInt(targetId.substring(4), 10)
            targetNode = @graph[targetId]

        if clientNode? and targetNode?
            context.strokeStyle = '#FF00FF'

            path = @findPath(clientNode, targetNode)

            length = path.length
            if length < 2
                return foreground

            for node in path
                nodePath = node.getPath()
                p1 = nodePath.x
                p2 = nodePath.y

                context.beginPath()
                context.moveTo(p1.x * @scale, p1.y * @scale)
                context.lineTo(p2.x * @scale, p2.y * @scale)
                context.stroke()
                context.closePath()

        return foreground

    # Gets the closest point on a line segment from another point.
    # Algorithm taken from: http://www.gamedev.net/topic/444154-closest-point-on-a-line/#entry3941160
    #
    # a
    #  one endpoint of the line segment
    # b
    #  the other endpoint of the line segment
    # p
    #  the point to find the closest point to on the line segment
    #
    getClosestPoint: (a, b, p) =>
        ap = p.clone().subtract(a)
        ab = b.clone().subtract(a)

        ab2 = ab.x * ab.x + ab.y * ab.y
        ap_ab = ap.x * ab.x + ap.y * ab.y

        t = ap_ab / ab2
        t = Math.min(t, 1)
        t = Math.max(t, 0)

        p = a.clone().add(ab.multiply(new Vector(t, t)))
        return p

    # Returns the node in the open list with the smallest cost so far.
    #
    # openList
    #         the list of nodes to examine
    #
    getNextNode: (openList) =>
        lowest = Number.MAX_VALUE
        correspondingNode = null

        for node in openList
            value = node.getCSF()

            if value < lowest
                lowest = value
                correspondingNode = node

        return correspondingNode

    # Implements Dijkstra's Algorithm to determine the shortest path to a destination.
    #
    # source
    #       the node where pathfinding will begin
    # target
    #       the node where pathfinding will end
    #
    findPath: (source, target) =>
        source.setCSF(0)

        openList = [source]
        closedList = []

        while openList.length > 0
            nodeX = @getNextNode(openList)

            for cost, nodeY of nodeX.getEdges()
                newCSF = nodeX.getCSF() + cost

                if nodeY in openList
                    if newCSF < nodeY.getCSF()
                        nodeY.setCSF(newCSF)
                        nodeY.setLastTraversed(nodeX)
                else if nodeY not in closedList
                    nodeY.setCSF(newCSF)
                    nodeY.setLastTraversed(nodeX)
                    openList.push(nodeY)

            i = openList.indexOf(nodeX)
            openList.splice(i, 1)
            closedList.push(nodeX)

            if target in closedList
                break

        path = []
        next = target

        while next != source
            path.push(next)
            next = next.getLastTraversed()

        path.push(source)

        winston.verbose("Shortest path found")
        return path
