/*
knurled_button.scad generates knurled knobs for bolts and nuts

GNU General Public License v3.0
Permissions of this strong copyleft license are conditioned on making available complete source
code of licensed works and modifications, which include larger works using a licensed work, under
the same license. Copyright and license notices must be preserved. Contributors provide an express
grant of patent rights.
 */

// Preferred knob height (will be overridden if too small)
knob_preferred_height = 13.91;
// Preferred knob diameter (will be overridden if too small)
knob_preferred_diameter = 14.91;
// Preferred knob contact diameter (will be overridden if too small or tool large)
knob_preferred_contact_diameter = 10.61;
// Preferred knurling step (will be overridden if too small or too large)
knob_preferred_knurling_step = 2.61;
// Used to compute and output the remaining thread length (it does not affect the knob dimensions) 
bolt_nominal_length = 20.09;
// Preferred bolt grip length (will be overridden if too small or too large)
bolt_grip_length = 4.61;
bolt_head_height = 3.79;
bolt_head_width = 7.95;
bolt_thread_diameter = 4.81;
// Knurling depth in percent of the available space
knurling_depth = 50; // [1:100]
// Cover hidding the bolt head
cover = "M"; // [N:None, S:Small, M:Medium, L:Large]
// Printer tolerance
printer_tolerance = 0.29;
// Printer nozzle diameter
nozzle_width = 0.4;
// Printer layer height
layer_height = 0.2;

/* [Hidden] */
// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

module knurled_knob(h = knob_preferred_height,
                    d = knob_preferred_diameter,
                    cd = knob_preferred_contact_diameter,
                    ks = knob_preferred_knurling_step,
                    kd = knurling_depth,
                    bnl = bolt_nominal_length,
                    bgl = bolt_grip_length,
                    bhh = bolt_head_height,
                    bhw = bolt_head_width, 
                    btd = bolt_thread_diameter,
                    co = cover,
                    pt = printer_tolerance,
                    nw = nozzle_width,
                    lh = layer_height) {

     function minimum_space() // Spacer value 
          = 3*nw;     

     function grip_length()
          = bolt_grip_length < 10*lh ? 10*lh : bgl;

     function knob_height() = ((co != "N") && (co != "None"))
          ? (h < bhh+pt+grip_length()+minimum_space() ? bhh+pt+grip_length()+minimum_space() : h)
          : (h < bhh+pt+grip_length() ? bhh+pt+grip_length() : h);

     function head_diameter()
          = 2*bhw/sqrt(3);

     function knob_diameter()
          = d < head_diameter()+2*minimum_space() ? head_diameter()+2*minimum_space() : d;

     function cover_diameter()
          = ((co == "L") || (co == "Large")) ? (knob_diameter()-2*bevel())
          : ((co == "S") || (co == "Small")) ? (head_diameter()+minimum_space())
          : (knob_diameter()-2*bevel()-(knob_diameter()-2*bevel()-(head_diameter()+minimum_space()))/2 ); // Default medium size

     function bottom_chamfer()
          = cd > knob_diameter()-2*(2*bevel()/3)/sqrt(2) ? 2*bevel()/3
          : (cd < head_diameter()+minimum_space() ? ((knob_diameter()-(head_diameter()+minimum_space()))/2)*sqrt(2)
             : ((knob_diameter()-cd)/2)*sqrt(2));

     function bevel()
          = min(knob_height(), (knob_diameter()-head_diameter())/2) * kd/100;

     // Nth turn of a cylinder of the same height as its diameter
     function twist(n)
          = 360/n*knob_height()/knob_diameter();

     // Generates a paired list of step values and circle arc lengths
     function pair_steps_and_lengths()
          = [ for (i = [1 : 360]) if (90 % i == 0) [90/i, knob_diameter()*3.14/i/4] ];

     // Browse the paired list and retains the length values,
     // find the closest length to the preffered value
     // output the corresponding step value
     function get_ideal_step(paired_list, desired_length)
          = max([ for (i = [0 : len(paired_list)-1 ],j = [0 : 1])
                          if (j % 2 != 0)
                               if (abs(paired_list[i][j]-desired_length)
                                   == min(
                                        [for (i = [0 : len(paired_list)-1 ], j = [1 : 2 : 1])
                                                   abs(paired_list[i][j]-desired_length)])) paired_list[i][j-1]]);

     module chamfer(chamfer_size, chamfer_z_position) {
          translate([0, 0, chamfer_z_position])
               rotate_extrude(angle = 360, convexity = 2)
               translate([knob_diameter()/2, 0, 0]) rotate([0, 0, 45])
               square(size = chamfer_size, center = true);
     }

     module screw_head() {
          translate([0, 0, grip_length()])
               cylinder(h=knob_height()-grip_length(), d=head_diameter()+pt, $fn=6);
     }

     module screw_thread() {
          cylinder(h=knob_height(), d=btd+pt);
     }

     module knurl_pattern() {
          for (j = [-1 : 2 : 1]) translate([0, 0, knob_height()/2]) {
               linear_extrude(height = knob_height(), center = true, convexity = 10, twist = j*twist(4)) {
                    for (i = [0 : get_ideal_step(pair_steps_and_lengths(), ks) : 360])
                         rotate([0, 0, i]) translate([-knob_diameter()/2, 0, 0]) circle(d=bevel(), $fn=3);
               }
          }
     }

     module cover(substraction=false) {
          if ((co != "N") && (co != "None")) {
               if (substraction == true) {
                    translate([0, 0, knob_height()-minimum_space()])
                         cylinder(h=minimum_space(), d=cover_diameter()+pt);
               } else {
                    translate([(knob_diameter()+cover_diameter())/2+minimum_space(), 0, 0])
                         cylinder(h=minimum_space(), d=cover_diameter());
               }
          }
     };

     module get_dimensions() {
          echo(
               "KNOB HEIGHT",
               knob_height(),
               "difference from preference",
               (knob_height()-knob_preferred_height));

          echo("KNOB DIAMETER",
               knob_diameter(),
               "difference from preference",
               (knob_diameter()-knob_preferred_diameter));

          echo("KNOB CONTACT DIAMETER",
               knob_diameter()-2*bottom_chamfer()/sqrt(2),
               "difference from preference",
               knob_diameter()-2*bottom_chamfer()/sqrt(2)-cd);

          echo("KNOB GRIP LENGTH",
               grip_length(),
               "difference from preference",
               (grip_length()-bolt_grip_length));

          echo("KNURLING STEP IN MM",
               knob_diameter()*3.14/(get_ideal_step(pair_steps_and_lengths(), ks)),
               "difference from preference",
               knob_diameter()*3.14/(get_ideal_step(pair_steps_and_lengths(), ks))-ks);

          echo("BOLT REMAINING THREAD LENGTH", bolt_nominal_length-grip_length());
     };

     // Main
     difference() {
          color("green", 0.5) cylinder(h=knob_height(), d=knob_diameter());
          color("blue", 1.0) chamfer(bevel(), knob_height());
          color("blue", 1.0) chamfer(bottom_chamfer(), 0);
          color("purple", 1.0) screw_head();
          color("purple", 1.0) screw_thread();
          color("orange", 1.0) knurl_pattern();
          color("cyan", 1.0) cover(true);
     }

     color("cyan", 1.0) cover(false);

     get_dimensions();
}

// Customizer
knurled_knob();
