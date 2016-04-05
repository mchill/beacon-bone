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

## Distance Calculation

1. For each message received from a beacon, plug the rssi into the formula above
2. Distance equals the average of these calculations over time
3. Remove distances from the list after two seconds

## Location Calculation

1. If no active beacons, assume distance is unchanged since last calculation
1. If one active beacon, location equals the location of that beacon
2. If two or more active beacons:
    a. Find the two beacons with the strongest rssi
    b. Assume the user is on a line connecting the two beacons
    c Determine the point on that line using the proportion of the two rssi's

## Graph Construction

1. Associate each node in the graph with a region of accessible space
2. Determine which region the user is in based on the location calculated above
3. The user's location is then described by a graph node

## Pathfinding

1. Determine the user's current node as described above
2. Determine the target node
3. Pass that information to an Dijkstra's algorithm
4. Return an ordered list of nodes that the user must traverse to reach the target