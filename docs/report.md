# Table of Contents
* [Problem Statement](#problem-statement)
* [Development Plan](#development-plan)
  * [Timeline](#timeline)
  * [Team Responsibilities](#team-responsibilities)
  * [Learning Objectives](#learning-objectives)
* [High Level Design](high-level-design)
  * [Platform](platform)
  * [Decomposition](decomposition)
* [Low Level Design](low-level-design)
* [Results](results)

# Problem Statement

While outdoor positioning has become very reliable through technology like
the GPS, cheap and accurate indoor positioning is still a challenge yet to be
solved. Our goal is to provide one possible solution to that challenge.

Our indoor positioning system, the BeaconBone, will rely on a variable number
of Bluetooth beacons statically placed in our indoor environment, Engineering
Building 2 (EB2). BeagleBone Blacks (BBBK) will move through the environment,
scanning for the beacons and measuring signal strength. With this system we
will be able to determine the approximate location of each BBBK in the
environment. We will be able to provide directions to any BBBK or region of
the environment via a map displayed on a webpage.

# Development Plan

## Timeline

The diagram below details our project development phases and timeline. The
design and implementation is divided into six components: distance finding,
positioning, networking, mapping, pathfinding, and output. Tasks are listed
under each component. The name of the team member responsible for each task
is in parentheses under the task. Our weekly milestones are listed on the
right-hand side.

![Timeline](timeline.png)

## Team Responsibilities

* Van is responsible for: 1.2, 1.3, 3.1, 3.2, 5.1
* Max is responsible for: 1.2, 2.2, 4,1, 4.3, 5.2
* Matt is responsible for: 1.1, 1.2, 2.1, 4.2, 5.3

## Learning Objectives

The goal of implementing the BeaconBone is to become more familiar with
Bluetooth technology and protocols as well as the positioning algorithms we
are planning to implement. Creating a system that coordinates the
communication of one device with multiple Bluetooth beacons will allow us to
achieve a greater understanding and expertise with Bluetooth protocol. The
underlying positioning algorithms that we will be implementing will also give
us an idea of the effort and technical precision that would be needed to go
into a system similar to this one in a real setup.

### Van

* Learn how to make a MQTT Broker receives topics from BBBKs
* Learn how a BBBK publishes and subscribes a topic
* Learn how a MQTT Broker works
* Look into the best way to display Bluetooth beacons on what is essentially
  a tree of nodes
* Learn the best way to implement Dijkstra’s Algorithm efficiently
* Determine the best way to refresh the path in a changing environment

### Max

* Learn how to efficiently convert positions into a series of nodes
* Look into the best way to display Bluetooth beacons on what is essentially
  a tree of nodes
* Learn the best way to implement Dijkstra’s Algorithm efficiently
* Determine the best way to refresh the path in a changing environment

### Matthew

* Research the precision of RSSI in Bluetooth technology
* Determine the best way to measure distance using RSSI
* Find the best graph representation of EB2 to use for positioning and
  pathfinding
* Learn how to host a simple HTTP server on a BBBK
* Learn how to use sockets to update the map

# High Level Design

## Platform / Areas

The BeaconBone is an application of sensing and location tracking technology.
It consists of a collection of Bluetooth beacons and BBBKs. The BBBKs use
attached Bluetooth dongles to scan for beacons and parse the messages that
they transmit. We will be using Radius Networks RadBeacon Dots for our
Bluetooth beacons, as well Plugable USB 4.0 Bluetooth dongles and Edimax Wifi
dongles.

Given the received signal strength indicator (RSSI) data of the Bluetooth
beacons, we will determine the distance between the BBBKs and beacons. Using
those distances, we can approximate the location of the BBBKs in the
environment. We can then apply Dijkstra’s pathfinding algorithm to provide a
path to other BBBKs or a static predetermined region of EB2 through the web
server.

Each BBBK is running the Debian Wheezy operating system, although the
platforms for publishing BBBKs, the MQTT broker, and the HTTP server are not
strictly interdependent. Testing is performed both on the BBBKs and on our
personal computers running Ubuntu. All code is written in CoffeeScript, a
language which trans-compiles into JavaScript. We use Node.js to run that
code server-side on our BBBKs.

## Decomposition

Our project is broken into six major components: distance finding, mapping,
positioning, networking, pathfinding, and output. Each component operates
independently except for a few exceptions, but the combination of them is
required to create a whole and functional indoor positioning system.

### Distance Finding

A BBBK will scan for Bluetooth beacons in its vicinity, which covers roughly
a 10 to 15 meter radius around the BBBK. The strength of the received signal
is measurable by the Bluetooth dongle, which will help to approximately
estimate distance from the beacon. Each beacon also transmits some data that
includes its unique identifier and the advertised signal strength at 1 meter.
Using the advertised signal strength and the actual signal strength, we will
be able to calculate the current distance to the beacon by applying a formula
that relates signal strength and distance. Furthermore, because signal
strength can vary greatly, we keep an average of calculated distances over a
period of time to lessen the influence of interference and outliers.

### Mapping

The map will be the backbone of our positioning system as it will be the
blueprint for the positioning data that each BBBK will be recording. A map of
the hallways of the CSC side of EB2 will be stored on each BBBK. This map
breaks the hallway into regions as depicted below: each white box represents
an area accessible to someone on the network, the black areas are
inaccessible, red circles represent a node on the tree of accessible rooms,
and each blue circle represents a Bluetooth beacon. This map will be depicted
on a web page that will be reachable by anyone that knows the address, and on
it we will be able to display the positions of each BBBK to the user. This
web page will also be where we display the paths from one BBBK on the network
to another.

![Map](eb2.png)

### Positioning

BBBKs will calculate their own positions locally by scanning for beacons
placed around the demo area (EB2). The location calculation algorithm varies
depending on the number of active beacons. If no active beacons are
available, it is assumed that the BBBK is no longer in the demo area. If
there is one active beacon is available, location of a BBBK is that of the
beacon. If there are two or more active beacons in the system, the BBBK will
find the two beacons with the strongest RSSI and assuming the BBBK is on the
line connecting the two beacons, using the proportion of the two RSSIs to
determine where on that line it lies. If the determined location is in
inaccessible space, the BBBK will use the position of the beacon with the
strongest RSSI.

### Networking

We will use MQTT, a standard built on top of TCP, for communication between
BBBKs. BBBK 1 will act as the broker and HTTP server. Additional BBBKs on the
network will publish their position to the broker. The HTTP server will
subscribe to all the positions of any active BBBKs currently on the map. This
architectural design allows for an unlimited number of BBBKs to interact in
the environment. If there are at least two active BBBKs publishing their
positions, then the server will be able to combine that data to calculate a
path from the first BBBK to the second.

BBBKs will calculate their own positions locally by scanning for beacons
placed around the demo area (EB2). The location calculation algorithm varies
depending on the number of active beacons. If no active beacons are
available, it is assumed that the BBBK is no longer in the demo area. If
there is one active beacon is available, location of a BBBK is that of the
beacon. If there are two or more active beacons in the system, the BBBK will
find the two beacons with the strongest RSSI and assuming the BBBK is on the
line connecting the two beacons, using the proportion of the two RSSIs to
determine where on that line it lies. If the determined location is in
inaccessible space, the BBBK will use the position of the beacon with the
strongest RSSI.

### Pathfinding

The manner in which we created the map of EB2 is such that we can easily
build a tree of all the accessible regions on the map. Upon having one BBBK’s
region, we can assign it to a corresponding node on the tree. Once we have at
least two BBBK’s regions recorded, we then have all the data that we’ll need
in order to display a path from one BBBK’s region to the other’s region.

When two or more BBBKs are publishing their positions, the user can add HTTP
query strings to the web page URL (see the output section) to acquire the
shortest path from its registered BBBK to a second one defined in the
command. The HTTP server will run a an implementation of Dijkstra’s Algorithm
to calculate a distance between the two pertinent nodes. This path will be
displayed on the map so that the user of the BBBK which made the command can
effectively travel to the location of the other BBBK. The path will also
update every time that the user changes regions so that the map and path both
stay accurate.

### Output

The output component of the project is how users will be able to view BBBKs
in the environment and receive instructions from the pathfinding algorithm.
This will be achieved through a simple HTTP web page containing a dynamic
image of the indoor environment. Refreshing the page will not be necessary;
the image will update automatically as new data is retrieved from the MQTT
broker. By default, the map will show all BBBKs currently publishing their
positions to the broker. Customization is implemented through HTTP query
strings. Users can specify their own BBBK and the BBBK or region of the map
to track this way.

Originally in the project proposal, there was no way to view the map of EB2.
The output component was instead going to be based on the onboard LEDs on the
BBBKs. The LEDs would blink in certain patterns to indicate directions that
the user should turn. That method of output also relied on using a magnetic
compass to determine the direction that the user was facing. That method was
flawed because it required the user to hold the BBBK in the same orientation
at all times. It also relied on the position calculations to be accurate
enough to determine exactly when the user reached a turn in the path, an
assumption that we are no longer comfortable making based on initial
experimentation.

Through discussion with our instructor after the project proposal, we decided
that it was necessary to somehow display a map of EB2 for testing purposes.
We expanded that idea so that the map will be our main form of user
interaction, and therefore the component that closes the loop for the
BeaconBone. Because we now have a more proficient form of output and user
direction, it is no longer necessary or even beneficial to give direction via
LEDs. As a result, we have removed that subset of the project and removed the
magnetic compass as a required sensor.

# Low Level Design

## Distance Finding

The first step to calculate the distance from a beacon is to derive an exact
relationship between signal strength and distance in our specific
environment. The general form of that relationship is as follows:

y(x) = a(xx1)b + c

where:
y = distance in meters, always positive
x = measured RSSI in dBm, always negative
x1 = advertised RSSI at one meter, always negative
a, b, c = constants, always positive

To solve for the three constants, we need to measure three initial values.
The easiest solution is to measure RSSI at one, two, and three meters away
from the beacon. To try to obtain the most accurate values possible, an
average of RSSI over one minute will be collected for all ten beacons and all
three positions. These measurements will give us the following:

y(x1) = 1, y(x2) = 2, y(x3) = 3

With those equations, there is enough data to determine our exact distance
formula. The other important aspect of calculating distance is ensuring that
the distance that is published to the broker is as accurate as reasonably
possible. Based on some initial experimentation, signal strength received by
the beacon can be very unstable. Factors such as the rotation of the beacon,
interference by an object between the Bluetooth dongle and the beacon, and
even simply power fluctuations can cause an error in the distance calculation
as big as several meters.

Over time, though, the signal seems to more or less follow a binomial
distribution centered on the actual distance from the beacon. We have to take
an average of distances over some period of time, removing old distances
along the way, to report a reasonable distance. That period of time has to be
long enough to gather enough data to get a stable average, but also short
enough that there is not significant lag between calculated distance and
actual distance as the BBBK moves through the environment. Although the
length of time has not been set in stone yet, some experimentation has
revealed that two seconds may work fairly well.

## Mapping

The map will be constructed on the HTTP server and displayed on a webpage.
This HTTP server will be the only subscriber in the BeaconBone system. When a
BBBK publishes its position to the broker through MQTT, the server will then
subscribe to the broker. The map has a walkable space that is broken into
regions labeled 1 through 11; a user in the network can only be in one of
these 11 regions. The map itself is a cartesian plane starting at (0,0) in
the bottom left hand corner. The position data or each BBBK will be sent in a
simple string of the format (x,y). The server will then register the BBBK’s
position and display it as being in the region that that coordinate falls in.
The HTTP server will also run the pathfinding algorithm when the user
requests for a path to another BBBK on the network.

## Positioning

To determine the position of a BBBK it will run the distance finding
algorithm and pick the two closest beacons. After it has determined its
distance to the two closest beacons it will calculate its position based on
the proportion of the two distances. It will also determine which region it
is in based on that position.

If there are errors with the detection of the beacons closest to the BBBK we
have developed protocols to handle them. If no beacons are detected by the
BBBK then the system assumes that the BBBK is no longer in the environment.
If only one beacon is detected then the position of the BBBK is the same as
that of the beacon. If the calculated position of the BBBK is in the
inaccessible black space of the map then the position of the BBBK is
estimated to be the same as that of the beacon with the strongest RSSI,
ignoring the beacon with the second highest RSSI. And in the incredibly
unlikely case that the distance to three or more beacons is calculated to be
equal, two beacons will be chosen from the set such that the position of the
BBBK is determined to be closest to the last calculated position of the BBBK.

The reason behind splitting the map into a series of accessible regions is
that the accuracy and precision of our positioning system is not high enough
to always confidently give a precise position along a path in the hallway,
and therefore declaring each BBBK to be in a region will more accurately
represent the user’s true location. A side effect of this design decision is
that a series of accessible regions makes for a tidy tree that will aid in
our pathfinding algorithm.

## Networking

Instead of having BBBKs directly send their positions to the HTTP server
using TCP, we chose to implement inter-BBBK communication via MQTT for a few
reasons. First, MQTT more easily allows us to connect the asynchronous design
of both beacon sensing on publishing BBBKs and map image creation on the HTTP
server. The two actions should not have to be synced together, as that would
cause added latency in communication and added complexity in our code. Using
MQTT, the publishing BBBKs can detect beacons and calculate position at a
rate independent of the rate that the HTTP server refreshes a map. In fact,
the HTTP server will be refreshing the map at rates independent for each
client connected to the website.

The next way that MQTT helps our project design is by adding an indefinite
ability for expansion. To add more BBBKs moving around the environment, they
simply have to run the publisher script. No extra configuration is required,
whereas using TCP in a one-to-one or one-to-X design would require
significant changes to the code to allow for additional BBBKs. Another
possibility added by our design is the ability to have multiple HTTP servers.
As the load on one server reaches a limit, we could easily start up more
servers on other BBBKs. Those servers simply subscribe to the broker. While
we don’t have the resources to demonstrate this, it’s a nice feature that
would be very useful for large-scale implementations of our project in a
real-world scenario.

BBBKs publish their positions to the broker under the topic “positions/id”,
where “id” is the MAC address of the device. We use MAC addresses because it
is an easy way to mostly guarantee unique identification as more BBBKs are
added to the environment, making it another feature supporting expandability
in our project. The HTTP server subscribes to all BBBKs’ positions using the
topic “positions/#”, a feature of MQTT that makes the one-to-many
relationship in our design much easier to implement.

## Pathfinding 

Our pathfinding algorithm is based completely on Dijkstra’s Algorithm. We
made this decision because it will allow us to effectively find the most
efficient path from one BBBK on the network to another. To perform Dijkstra’s
algorithm we had to assign each link in the tree a cost that represented the
distance from one region to the next (those costs are depicted below). 

To code Dijkstra’s algorithm we needed to employ a priority queue that holds
all region nodes and would loop through to remove the one with the lowest
distance from the source. We would add the nodes adjacent to the ones we
remove to the end of the queue. As the loop progresses through the queue the
desired destination node will eventually be the next to  be removed and we
will be able to display this as the shortest path from one BBBK to another.

## Output

Output in our project will be handled by an independent HTTP server running
on BBBK 1 alongside the MQTT broker. However, the server can be run on BBBK
or computer with the same effect. Users will be able to navigate to the IP
address of BBBK 1 on a web browser. In the case of demoing the project, we
will have users walking around the environment open the page on a smartphone.
Ideally a display would be attached to the same device that is scanning for
Bluetooth beacons, which would require a screen for the BBBKs to attach to.

When users browse the web page, the default view will be a diagram of the map
of EB2 similar to the one shown in this report. The map will include all
BBBKs actively publishing positions to the broker, as the server gets data by
subscribing to all BBBK positions. A user can specify their own BBBK by
adding “?bbbk=#” to the end of the URL. The pound sign should be replaced by
the ID of the BBBK that the user is holding. Although devices are
distinguished by the MQTT broker using MAC addresses, integer aliases have
been assigned to our BeagleBones for ease of use. The map will then highlight
the specified BBBK in a different color than the others to distinguish it.
Also, the general region in which the BBBK is located will be outlined. The
outlined region should be far more reliable than the specific position
displayed on the map.

Pathfinding is requested in a similar fashion. In addition to specifying
their own BBBK, a user can specify a BBBK to track by adding “target=#” to
the end of the URL. To specify a region of the map instead of another BBBK to
show a path to, “target=node#” can be added to the end of the URL, where the
pound sign is replaced by the number of the region in EB2 as defined by the
map depicted earlier in the report. The map will then display a line moving
through the shortest path between the user and the target. As the user moves
towards the target, the path will be updated accordingly. When the user
enters the same region as the the target, pathfinding is complete and some
indication of success will be displayed.

# Results

After months of development and gathering data for our self studies, we
performed two test runs and a final demonstration. Several things went wrong
during the first test run. This was the first time that we used our battery
packs for an extended period of time. We began to experience serious problems
with these, as our BBBKs would restart without warning. A single publisher
restarting is not a big deal in our system, but when the BBBK running the
HTTP server or MQTT broker loses power, the entire system is useless until it
comes back online. Our solution to this problem was to keep the BBBKs wired
to our laptops, which while it was unfortunate, did not affect our project
badly.

The next problem that we encountered during testing was actually far more
serious than the first. Our BBBKs would sporadically disconnect from the NCSU
wireless internet, and in the majority of cases would fail to reconnect
without restarting them completely. Once again, the problem negatively
affected the server and broker a lot more than the publishers. That is
because the IP address of the publishers is unimportant to the system, but
the server’s and especially the broker’s IP address must stay static. If the
broker’s IP address changes, the server and publishers must all be restarted
to specify that change. If the server’s changes, all users that wish to view
the map must be given the new address to navigate to. We decided at this
point in testing that we would run the server and broker on one of our
laptops during the final demonstration to ensure that everything would
function as smoothly as possible.

On the day of the final demonstration, we encountered a problem that plagued
us occasionally throughout the semester. We couldn’t connect to any of our
BBBKs using SSH despite countless restarts of our laptops and BBBKs. The
problem had never happened to all of us at once, and therefore had never
affected us too badly since only two machines need to be involved in a fully
functional BeaconBone system. Since we could not open the console to run the
publisher program, we were forced to use our laptops as publishers as well as
the server and broker. We had never tried that configuration before, but
luckily we were able to set up the project and get the programs running
quickly.

During the demonstration, the system worked mostly as expected. The
publishers detected their own positions in the correct region the majority of
the time, sometimes shifting to an adjacent region for a moment before coming
back. The inaccuracy was almost never more than a single region away. The
accuracy of position within regions was fairly poor as we expected after
testing we did during beacon configuration. Bluetooth signal is much better
suited for determining general proximity as opposed to exact location. The
communication between the different services in the system was only rarely
disrupted, and those disruptions lasted for only a second or two at a time. A
bug arose where a source and target BBBK specified by one web client could
propagate to other web clients’ maps, causing the color of the BBBK on the
map to change. It wasn’t a serious issue, but it would definitely be a
nuisance if BeaconBone were deployed in a larger scale where many clients
view the map simultaneously.

The other aspects of the project - the MQTT broker, pathfinding, transfer of
data through publishing and subscribing, etc. - worked as expected. Overall,
our results were satisfying, and we believe that a system like BeaconBone
could have benefits in a real-world application, but only if several changes
are made. The system should not be used for positioning in such a small
environment as we chose. An environment more suited to Bluetooth positioning
could be a large department store, in which customers could obtain directions
to general areas like men’s clothing or toys. Stores could even use the
system to apply gamification to shopping, requiring shoppers to go on
scavenger hunts to obtain special deals. While we learned a lot developing
this project, the main takeaway is that Bluetooth, at least in its current
state, is not the perfect solution for indoor positioning.
