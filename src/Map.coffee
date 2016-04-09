Canvas = require('canvas')
Vector = require('victor')
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
            context.arc(beacon.x * @scale, beacon.y * @scale, @scale / 2, 0, 2 * Math.PI);
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

        context.fillStyle = "#FF0000"
        for index, trackedItem of trackedItems
            position = trackedItem.getPosition()

            context.beginPath()
            context.arc(position.x * @scale, position.y * @scale, @scale / 2, 0, 2 * Math.PI);
            context.fill()
            context.closePath()

        return foreground
