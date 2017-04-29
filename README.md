# hoppingrob
./ArrayGener

'test.m' is the test code for testing all the functions.
'ArrayGener.m' creates the hash table mapping input and IC to output of dynamics system. The function return a cell whose index represents  the input 'u'. Each element in the cell is a nxn matrix, the hash table maping x0 to xt w.r.t u.
'odefun.m' defines the dynamic system.

The code is quite time-consuming due to the ode solver. The code is optimized based on time-priority, which means that more space may be taken for a shorter running time. The situation may reverse as the scale of the abstruction system increases.
