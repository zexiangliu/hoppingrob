# hoppingrob

## File Structure

Test code: [test/](./test/)

Libraries: [lib/](./lib/)

Demos: [demo/](./demo/)

## How to run demos

Firstly, please move to folder [demo/](./demo/). 
```
cd demo/
```

Specify a demo to run:
```
run_example(PATH)
```
where PATH is the path of the demo's folder, e.g. './push_recovery/case1/'.



Alternatively, you can use the console designed for executing demos, which is run by:
```
run_example()
```


If you enter the console successfully, you will see the prompt has become
```
manual$
```

You can look at the help infomation for the usage of commands available.
```
manual$ h
```

To check the demos available, 
```
manual$ list
```

To learn more about one demo,
```
manual$ doc "demo's name"
```

To run a demo in the list, just type its name printed by command 'list'
```
manual$ "demo's name"
```
or
```
manual$ exec num
```
where 'num' is the number shown ahead the demo's name in the printed list.

If you don't want to wait for a long time for abstraction generation, you can use fast mode
```
manual$ "demo's name" -f
```
or
```
manual$ exec num -f
```
# Authors
Zexiang Liu, University of Michigan, zexiang@umich.edu

Ozay Necmiye, University of Michigan

# Third-party Library
[ABSTR-REFINEMENT TOOLBOX](https://github.com/pettni/abstr-refinement)

