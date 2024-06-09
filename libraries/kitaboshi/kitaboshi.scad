/*
kitaboshi.scad generates barrel for the Kita-Boshi 2mm mechanical pencil

GNU General Public License v3.0
Permissions of this strong copyleft license are conditioned on making available complete source
code of licensed works and modifications, which include larger works using a licensed work, under
the same license. Copyright and license notices must be preserved. Contributors provide an express
grant of patent rights.
*/

// Pen shape
cylindric = false;
// Pen grip
grip = false;

// Printer tolerance
printer_tolerance = 0.2;

/* [Hidden] */
// Default barrel dimensions
barrel_length = 132.5;
barrel_diameter = 8.7;
lead_chamber_diameter = 4.5;
thread_diameter = 5.5;
thread_length = 20.0;

// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

module kitaboshi( cy = cylindric,
                  gr = grip,
                  pt = printer_tolerance ) {

     // Barrel
     module barrel() {
          sides = cy ? 180 : 6;
          difference() {

               // External shape
               linear_extrude(height = barrel_length, center = false, convexity = 10, twist = 0)
                    offset(r = (barrel_diameter/sides)/2)
                    circle(d = barrel_diameter-(barrel_diameter/sides), $fn = sides);

               // Lead hole
               cylinder(h = barrel_length-thread_length, d = lead_chamber_diameter+pt);

               // Thread hole
               translate([0, 0, barrel_length-thread_length])
                    cylinder(h = thread_length, d = thread_diameter+pt);
          }
     }

     // Grip substractive pattern
     module grip() {
          translate([0, 0, 2*barrel_length/3])
               for (i = [0 : barrel_diameter-barrel_diameter*sqrt(3)/2 : barrel_length/4])
                    translate([0, 0, i])
                         rotate_extrude(angle = 360, convexity = 2)
                         translate([barrel_diameter/2, 0, 0])
                         rotate([0, 0, 30])
                         circle(d = (barrel_diameter/2)-barrel_diameter*sqrt(3)/4, $fn = 6);
     }

     // Main
     difference() {
          color("Goldenrod", 1) barrel();
          if (gr) {
               color("YellowGreen", 1) grip();
          }
     }
}

// Customizer instantiation
kitaboshi();
