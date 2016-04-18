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
    #
    getCanvas: (trackedItems) =>
        foreground = new Canvas(32 * @scale, 23 * @scale)
        context = foreground.getContext('2d')
        context.drawImage(@background, 0, 0)

        for index, trackedItem of trackedItems
            context.fillStyle = '#0000FF'

            if trackedItem.isClient()
                context.fillStyle = '#00FF00'
                client = trackedItem
            else if trackedItem.isTarget()
                context.fillStyle = '#FF0000'
                target = trackedItem

            position = trackedItem.getPosition()
            node = trackedItem.getNode()

            path = node.getPath()
            position = @getClosestPoint(path.x, path.y, position)

            if trackedItem.isClient()
                region = node.getRegion()
                context.strokeStyle = '#00FF00'
                context.strokeRect(region.x.x * @scale, region.x.y * @scale, region.y.x * @scale, region.y.y * @scale)

            context.beginPath()
            context.arc(position.x * @scale, position.y * @scale, @scale / 2, 0, 2 * Math.PI)
            context.fill()
            context.closePath()

        if client? and target?
            context.strokeStyle = '#FF00FF'
            path = findPath(client, target)

            length = path.length
            first = path[0].getPath()
            second = path[1].getPath()
            last = path[length-1].getPath()
            secondToLast = path[length-2].getPath()

            if first.x.x == second.x.x and first.x.y == second.x.y
                firstPoint = first.x
            else if first.x.x == second.y.x and first.x.y == second.y.y
                firstPoint = first.x
            else if first.y.x == second.x.x and first.y.y == second.x.y
                firstPoint = first.y
            else if first.y.x == second.y.x and first.y.y == second.y.y
                firstPoint = first.y

            context.beginPath()
            context.moveTo(client.getPosition().x * @scale, client.getPosition().y * @scale)
            context.lineTo(firstPoint.x * @scale, firstPoint.y * @scale)
            context.stroke()
            context.closePath()

            if last.x.x == secondToLast.x.x and last.x.y == secondToLast.x.y
                lastPoint = last.x
            else if last.x.x == secondToLast.y.x and last.x.y == secondToLast.y.y
                lastPoint = last.x
            else if last.y.x == secondToLast.x.x and last.y.y == secondToLast.x.y
                lastPoint = last.y
            else if last.y.x == secondToLast.y.x and last.y.y == secondToLast.y.y
                lastPoint = last.y

            context.beginPath()
            context.moveTo(target.getPosition().x * @scale, target.getPosition().y * @scale)
            context.lineTo(lastPoint.x * @scale, lastPoint.y * @scale)
            context.stroke()
            context.closePath()

            path.shift()
            path.pop()

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

    # Utility function to aid in finding the least expensive node for Dijkstra's Algorithm
    #
    # dist
    #	  Array holding the cost of each node from the source node
    # closed
    #		An Array of Booleans representing if a node is part of the final path or not
    getMinDistance: (dist, closed) =>
    	min = 100
    	minIndex = -1

    	for int, index in dist
    		if (!closed[index] && dist[index] < min){
    			min = dist[index]
    			minIndex = index
    		}

    	return minIndex

    # Implements Dijkstra's Algorithm to determine the shortest path to a destination
    #
    # srcTrackedItem
    #               The client item where pathfinding will begin
    #
    # destTrackedItem
    #                The target item where pathfinding will end
    findPath: (srcTrackedItem, destTrackedItem) =>
        
        srcNode = srcTrackedItem.getNode()
        srcNodeIdx = @graph.indexOf(srcNode)
        destNode = destTrackedItem.getNode()
        destNodeIdx = @graph.indexOf(destNode)
        nodes = []
        [0..11].closed -> false
        [0..11].dist -> 100

        dist[srcNodeIdx] = 0
        srcNode.setCSF(0)

        for int in dist

        	u = getMinDistance(dist, closed)

        	closed[u] = true
        	nodes.push @graph[u]

        	if(@graph[u] == destNode)
        		break

        	for node, idx in graph
        		if(idx == u){
        			edges = node.getEdges()
        			for edge, weight of edges
        				graphIdx = @graph.indexOf(edge)
        				if(!closed[graphIdx]){
        					edge.setCSF(node.getCSF()+weight)
        					dist[graphIdx] = edge.getCSF()
        				}
        		}

        	
        	if(srcNodeIdx > destNodeIdx)
        		for node, index in nodes
        			nodeIdx = @graph.indexOf(node)
        			if( nodeIdx > srcNodeIdx || nodeIdx < destNodeIdx)
        				nodes.splice(index, 1)

        	if(srcNodeIdx < destNodeIdx)
        		for node, index in nodes
        			nodeIdx = @graph.indexOf(node)
        			if( nodeIdx < srcNodeIdx || nodeIdx > destNodeIdx)
        				nodes.splice(index, 1)

        	winston.verbose("Shortest path has been found.")

        return nodes
