# ROC

I was looking for a small project to try Elixir on, ROC (https://reaktor.com/orbital-challenge/) fit the bill perfectly.
This is my first Elixir project, so there is a lot to improve. Anyways, it was nice to try new approach for problem solving.

## Usage

You need to have Elixir (http://elixir-lang.org/).

Execute 

> mix escript.build

to build the project. This produces 'roc' executable, which takes the satellite data file name as parameter, and print outs the route. Route is optimized for hops by default, option --hops=false optimizes for path length. 

Example:

> ./roc data/sat.lst --hops=true
  ["START", "SAT8", "SAT14", "SAT2", "SAT1", "SAT15", "END"]

