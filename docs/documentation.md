# Documentation

## Map

![Map](eb2.png)

Key:
- White area - accessible regions
- Black area - inaccessible regions
- Blue circle - Bluetooth beacon location
- Red circle - graph node
- Red outline - accessible region defined by a node

## Determining Distance Formula

1. Take the 60 second average of rssi for all beacons at 1, 2, and 3 meters
2. Find the average over all beacons for each of the three distances
3. Call the averages x1, x2, and x3
4. Solve for the formula `y(x) = a * (x / x1)^b + c`, where
    - y = distance in meters, always positive
    - x = rssi, always negative
    - a,b,c = constants, always positive

### Data

Beacon  |1 meter | 2 meters | 3 meters
------- |------- | -------- | --------
1       | -61    | -69      | -72
2       | -61    | -68      | -71
3       | -61    | -69      | -71
4       | -61    | -69      | -71
5       | -61    | -71      | -73
6       | -61    | -68      | -71
7       | -61    | -68      | -73
8       | -61    | -68      | -72
9       | -61    | -69      | -72
10      | -61    | -69      | -72
------- | ------ | -------- | --------
Average | -61    | -68.8    | -71.8

### Results

`y(x1) = 1`, `x1 = -61`
`y(x2) = 2`, `x2 = -68.8`
`y(x3) = 3`, `x3 = -71.8`

`a = 0.24`, `b = 13.9`, `c = 0.76`

`y(x) = 0.24 * (-x / 61)^13.9 + 0.76`

## Distance Calculation

1. For each message received from a beacon, plug the rssi into the formula above
2. Distance equals the average of these calculations over time
3. Remove distances from the list after two seconds

## Location Calculation

1. If no active beacons, assume distance is unchanged since last calculation
2. If one active beacon, location equals the location of that beacon
3. If two or more active beacons:
    1. Find the two beacons with the strongest rssi
    2. Assume the user is on a line connecting the two beacons
    3. Determine the point on that line using the proportion of the two rssi's
    4. If that point is in inaccessible space
        * Use the position of the beacon with the strongest rssi

## Graph Construction

1. Associate each node in the graph with a region of accessible space
2. Determine which region the user is in based on the location calculated above
3. The user's location is then described by a graph node

## Pathfinding

1. Determine the user's current node as described above
2. Determine the target node
3. Pass that information to an Dijkstra's algorithm
4. Return an ordered list of nodes that the user must traverse to reach the target

## High-level Process

1. An MQTT server is setup on a BeagleBone
2. Other BeagleBones detect beacons and calculate distances and their own location
3. Those BeagleBones publish their positions to the MQTT broker
3. An HTTP server subscribes to all positions published on the MQTT broker
4. The server updates a map image regularly to show BeagleBone locations
    * To highlight your location, add the parameter bbbk=id (each BBBK is given an ID)
    * To show a path to another BBBK, add the parameters bbbk=id and target=id
    * If the target id is prefixed with "node", a path to a node instead of a bbbk will be found
