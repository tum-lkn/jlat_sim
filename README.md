# jlat_sim
Matlab simulation files for the paper 
Deadline-Aware Wireless Sensor Network Routing The JLAT Metric

All nodes are connected to each other. 

Idea is to generate arbitrary link qualities using the bursty behavior
generator Discrete-time Markov Model for wireless link Burstiness Simulation
This will be used to test a routing algorithm, that routes deadline based
packets. This than will be compared to B_max, ETX, Minhop.

The way to achieve this result is, first each node will generate a set of
packet losses and successes with the bursty simulation. This will be the
time track of these nodes. This time track will than be translated to a
routing metric. The question is should this be done live, or should this
be done in an offline way. Both can be tried out. Offline should be easier
to program. After this point, packets are generated at a random time and 
routed over the decided path. A link based acknowledgement is assumed thus
the packet is re-transmitted in each link until it goes to the next link.
The delay cumulative mass function of packet is logged. To point out the
capability of each routing metric to meet a deadline.
