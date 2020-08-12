/*
 * ikea_skadis.scad - IKEA Skådis pegboard library to generate 3D printable accessories
 * by François Polito
 * created 2019-04-22
 * OpenSCAD version 2019.05 
 * This work is licensed under the Creative Commons - CC0 1.0 Universal (CC0 1.0) - Public Domain Dedication .
 * https://creativecommons.org/publicdomain/zero/1.0/
 */

/* VARIABLES
 * *********/

// Coins dimension variables
c1t="5kr";		// String value for coin 1, (enter "" for no value)
c1d=23.75;		// Diameter of coin 1
c1h=1.95;		// thickness of coin 1
c2t="10kr";		// String value for coin 2, (enter "" for no value)
c2d=20.5;		// Diameter of coin 2
c2h=2.9; 		// Thickness of coin 2
 
/* The following table contains the coin dimensions for some currencies.

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
| ...      | ...   | ...      | ...       | */

// Resolution variables
$fa=1;			// default minimum facet angle
$fs=0.5;		// default minimum facet size


/* BOOLEAN OPTIONS
   ****************/
sla=true;
fdm=false;


/* FUNCTIONS
   *********/
function distance(diameter) = 3*diameter/4;
function engravure_thickness(height) = 2*height/5;
function engravure_z_position(height, boolean) = (boolean) ? 2*height/5 : 4*height/5;
function grip_z_position(height, boolean) = (boolean) ? -2*height/5 : -4*height/5;
function grip_width(height, diameter) = diameter/sqrt(2) / 7;
function minimum_height(height1, height2, boolean) = (boolean) ? 3*(min(height1, height2))/5 : 4*(min(height1, height2))/5;


/* MODULES
   *******/
module coin_position(diameter, angle, boolean) {
     translate([distance(diameter), 0, 0])
	  rotate([0, (boolean) ? 180 : 0, angle])
	  	children();
}

module coin(height, diameter, boolean) {
     cylinder(h = height,  d = diameter, center = boolean);
}

module string(height, diameter, string, boolean) {
     translate([0, 0, engravure_z_position(height, boolean)])
	  linear_extrude(engravure_thickness(height), center = boolean, convexity = 4)
	  	resize([diameter/sqrt(2), 0], auto = true)
	  		text(string, valign = "center", halign = "center");
}

module grip(height, diameter, boolean) {
     translate([0, 0, grip_z_position(height, boolean)]) intersection() {
	  for (l = [0:1])
	       mirror([0, 1*l, 0]) for (k = [grip_width(height, diameter)/2 : grip_width(height, diameter) : diameter/sqrt(2)/2])
		    translate([0, k, -engravure_thickness(height)/6])
			 for (i = 30, j = 90)
			      rotate([j, i, j])
				   cylinder(h = diameter/sqrt(2), d = 4*engravure_thickness(height)/3, $fn = 3, center = true);
	  cylinder(h = engravure_thickness(height), d = diameter/sqrt(2), center = true);
     }
}

module link(height1, height2, diameter1, diameter2, boolean) {
     difference() {
	  hull() {
	       translate([-distance(diameter1), 0, 0]) rotate([0, 0, 180])
		    cylinder(h = minimum_height(height1, height2, boolean),
			     d = 7*diameter1/10, $fn = 3, center = boolean);
	       translate([distance(diameter2), 0, 0])
		    cylinder(h = minimum_height(height1, height2, boolean),
			     d = 7*diameter2/10, $fn = 3, center = boolean);
	  }
	  translate([-distance(diameter1), 0, 0])
	       cylinder(h = minimum_height(height1, height2, boolean),
			d = 9*diameter1/10, center = boolean);
	  translate([distance(diameter2), 0, 0])
	       cylinder(h = minimum_height(height1, height2, boolean),
			d = 9*diameter2/10, center = boolean);
     }
}

module trolley_token(height1, height2, diameter1, diameter2, string1, string2, boolean = true) {
     union() {
	  coin_position(-diameter1, 90) difference() {
	       coin(height1, diameter1, boolean);
	       grip(height1, diameter1, boolean);
	       string(height1, diameter1, string1, boolean);
	  }
	  coin_position(diameter2, -90, boolean) difference() {
	       coin(height2, diameter2, boolean);
	       grip(height2, diameter2, boolean);
	       string(height2, diameter2, string2, boolean);
	  }
	  link(height1, height2, diameter1, diameter2, boolean);
     }
}

/* TOKEN GENERATION
   ****************
   Usage: trolley_token(coin_1_height, coin_2_height, coin_1_diameter, coin_2_diameter, coin_1_text, coin_2_text, true_or_false);

   The boolean parameter is optional. When it's undefined it will act as false. This boolean option permits to switch
   beetween two designs.

      1. a flat design appropraite for FDM prnters, exampel:

         trolley_token(c1h, c2h, c1d, c2d, c1t, c2t);
         trolley_token(c1h, c2h, c1d, c2d, c1t, c2t, fdm);
         trolley_token(2.14, 2.38, 22.25, 24.25, "0.2€", "0.5€", fdm);
         trolley_token(2.33, 2.38, 23.25, 24.25, "1€", "0.5€", false);
         
      2. a centered design appropriate for SLA printers 

         trolley_token(c1h, c2h, c1d, c2d, c1t, c2t, sla);
         trolley_token(c1h, c2h, c1d, c2d, c1t, c2t, true);
         trolley_token(2.8, 2.5, 23.43, 28.4, "1£", "2£t", sla);
*/