# hoppingrob
./ArrayGener

'test.m' is the test code for testing all the functions.

'ArrayGener.m' creates the hash table mapping input and IC to output of dynamics system. The function return a cell whose index represents  the input 'u'. Each element in the cell is a nxn matrix, the hash table maping x0 to xt w.r.t u.

'odefun.m' defines the dynamic system.

The code is optimized for a better performance on time, which sacrifices some storage space. However, as the scale of the abstruction system increases, the performance may be restricted by the reading speed of hard drive. Another branch is going to be created later which sacrifices CPU for less space.

---------------------------------------------------------------
./Simu

Create simulation of hopping robot and corresponding animation.

Run 'test.m' and 'test_control.m' one by one to test the code.
