/*
Demo script using kitaboshi.scad; it will generate an example of each possible barrel model 
*/

use <kitaboshi.scad>

// Distance between models iterations
distance = 20;

module kitaboshi_variations() {
     for (i=[0:1]) { // cylindric options
          for (j=[0:1]) { // grip options
               // convert binary values to decimal values and then
               // translate each model iterations by the defined distance
               translate([((j*2^1)+(i*2^0))*distance, 0, 0])
                    kitaboshi(cy=i, gr=j);
          }
     }
}

kitaboshi_variations();
