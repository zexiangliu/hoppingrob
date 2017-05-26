# Push Recovery

## Description

The hopping robot pushed by someone has a nonzero velocity. The control algorithm is applied to recover the robot to a stable (or near-stable) state. We assume that the robot is working in an environment which may be uneven and have holes.

Example: Contour of the ground

![ground](pic/ground.png)


We set up four different cases of push recovery:

### case 1
Even ground with holes. Do 1D planning without environment information (the worst case).

### case 2 
Even ground with holes. Do 1D planning given positions and sizes of the holes in the line the robot moves along. 

### case 3
Uneven ground without holes. Do 1D planning given maximum altitude difference *hlim*. (*lmax* shrinks based on *hlim*.)

Example: How the *lmax* shrinks:

![lmax](pic/lmax.png)

### case 4
Uneven ground with holes. Do 1D planning given the ground information in the line the robot moves along (holes and altitudes of nodes in input space). 

## Usage

