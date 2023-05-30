/*
Parametric trolley token generator

This work is licensed under the Creative Commons - CC0 1.0 Universal (CC0 1.0) - Public Domain Dedication.
https://creativecommons.org/publicdomain/zero/1.0/
*/

/* PARAMETERS
   **********/
// Trolley token
coin_1_thickness = 1.95;
coin_2_thickness = 2.9;
coin_1_diameter = 23.75;
coin_2_diameter = 20.5;
coin_1_string = "5kr"; // Coin 1 value
coin_2_string = "10kr"; // Coin 2 value
sla_printer = false;

// Resolution 
$fa=1; // default minimum facet angle
$fs=0.5; // default minimum facet size

/* FUNCTIONS
   *********/
function distance(diameter) = 3*diameter/4;
function engravure_thickness(height) = 2*height/5;
function engravure_z_position(height, sla) = (sla) ? 2*height/5 : 4*height/5;
function grip_z_position(height, sla) = (sla) ? -2*height/5 : -4*height/5;
function grip_width(height, diameter) = diameter/sqrt(2) / 7;
function minimum_height(height1, height2, sla) = (sla) ? 3*(min(height1, height2))/5 : 4*(min(height1, height2))/5;

/* MODULES
   *******/
module coin_position(diameter, angle, sla) {
     translate([distance(diameter), 0, 0])
	  rotate([0, (sla) ? 180 : 0, angle])
	  	children();
}

module coin(height, diameter, sla) {
     cylinder(h = height,  d = diameter, center = sla);
}

module string(height, diameter, string, sla) {
     translate([0, 0, engravure_z_position(height, sla)])
	  linear_extrude(engravure_thickness(height), center = sla, convexity = 4)
	  	resize([diameter/sqrt(2), 0], auto = true)
	  		text(string, valign = "center", halign = "center");
}

module grip(height, diameter, sla) {
     translate([0, 0, grip_z_position(height, sla)]) intersection() {
	  for (l = [0:1])
	       mirror([0, 1*l, 0]) for (k = [grip_width(height, diameter)/2 : grip_width(height, diameter) : diameter/sqrt(2)/2])
		    translate([0, k, -engravure_thickness(height)/6])
			 for (i = 30, j = 90)
			      rotate([j, i, j])
				   cylinder(h = diameter/sqrt(2), d = 4*engravure_thickness(height)/3, $fn = 3, center = true);
	  cylinder(h = engravure_thickness(height), d = diameter/sqrt(2), center = true);
     }
}

module link(height1, height2, diameter1, diameter2, sla) {
     difference() {
	  hull() {
	       translate([-distance(diameter1), 0, 0]) rotate([0, 0, 180])
		    cylinder(h = minimum_height(height1, height2, sla),
			     d = 7*diameter1/10, $fn = 3, center = sla);
	       translate([distance(diameter2), 0, 0])
		    cylinder(h = minimum_height(height1, height2, sla),
			     d = 7*diameter2/10, $fn = 3, center = sla);
	  }
	  translate([-distance(diameter1), 0, 0])
	       cylinder(h = minimum_height(height1, height2, sla),
			d = 9*diameter1/10, center = sla);
	  translate([distance(diameter2), 0, 0])
	       cylinder(h = minimum_height(height1, height2, sla),
			d = 9*diameter2/10, center = sla);
     }
}

module trolley_token(
     height1 = coin_1_thickness,
     height2 = coin_2_thickness,
     diameter1 = coin_1_diameter,
     diameter2 = coin_1_diameter,
     string1 = coin_1_string,
     string2 = coin_2_string,
     sla = sla_printer) {
     union() {
	  coin_position(-diameter1, 90) difference() {
	       coin(height1, diameter1, sla);
	       grip(height1, diameter1, sla);
	       string(height1, diameter1, string1, sla);
	  }
	  coin_position(diameter2, -90, sla) difference() {
	       coin(height2, diameter2, sla);
	       grip(height2, diameter2, sla);
	       string(height2, diameter2, string2, sla);
	  }
	  link(height1, height2, diameter1, diameter2, sla);
     }
}

/* USAGE
   *****
   To generate a token you must invoke the module trolley_token() which takes up to 7 parameters:

   1. height1 (numerical) - the thickness of the 1st coin
   2. height2 (numerical) - the thickness of the 2nd coin
   3. diameter1 (numerical) - the diameter of the 1st coin
   4. diameter2 (numerical) - the diameter of the 2nd coin
   5. string1 (string) - text field to enter the value of the 1st coin
   6. string2 (string) - text field to enter the value of the 2nd coin
   7. sla (boolean) - set to false the model will have a flat base convenient for fused filament fabrication

   The table below shows the coin dimensions of different currencies:

   | Currency | Value | Diameter | Thickness |
   |----------+-------+----------+-----------|
   | SEK      | 1 kr  | 19.5 mm  | 1.79 mm   |
   | SEK      | 2 kr  | 22.5 mm  | 1.79 mm   |
   | SEK      | 5 kr  | 23.75 mm | 1.95 mm   |
   | SEK      | 10 kr | 20.5 mm  | 2.9 mm    |
   | EUR      | 0.2 € | 22.25 mm | 2.14 mm   |
   | EUR      | 0.5 € | 24.25 mm | 2.38 mm   |
   | EUR      | 1 €   | 23.25 mm | 2.33 mm   |
   | EUR      | 2 €   | 25.75 mm | 2.20 mm   |
   | CHF      | 1 Fr  | 23.20 mm | 1.55 mm   |
   | CHF      | 2 Fr  | 27.40 mm | 2.15 mm   |
   | CHF      | 5 fr  | 31.45 mm | 2.35 mm   |
   | GBP      | 1 £   | 23.43 mm | 2.8 mm    |
   | GBP      | 2 £   | 28.4 mm  | 2.5 mm    |
   | ...      | ...   | ...      | ...       |

   Usage:
   translate([0, 15, 0])
       trolley_token(string1 = "$$", string2 = "€€");
   translate([0, 45, 0])
       trolley_token(2.15, 2.35, 23.2, 27.4, "2Fr", "5Fr", true);
   translate([0, -15, 0])
       trolley_token(2.14, 2.38, 22.25, 24.25, "0.2€", "0.5€", true);
   translate([0, -45, 0])
       trolley_token(2.33, 2.38, 23.25, 24.25, "1€", "0.5€", false);
*/

// Thingiverse customizer call
// https://www.thingiverse.com/thing:3586719
// trolley_token();
