# hoppingrob
./ArrayGener

'test.m' is the test code for testing all the functions.

'ArrayGener.m' creates the hash table mapping input and IC to output of dynamics system. The function return a cell whose index represents  the input 'u'. Each element in the cell is a nxn matrix, the hash table maping x0 to xt w.r.t u.

'odefun.m' defines the dynamic system.

The code is optimized based on high priority of time. More space may be taken up for saving time and CPU. The situation may reverse as the scale of the abstruction system increases. Another branch is going to be created later which sacrifices time for saving space.
