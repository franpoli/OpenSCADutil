/*
cabletie.scad generates cable ties primarly meant to be 3D printed in TPU

GNU General Public License v3.0
Permissions of this strong copyleft license are conditioned on making available complete source
code of licensed works and modifications, which include larger works using a licensed work, under
the same license. Copyright and license notices must be preserved. Contributors provide an express
grant of patent rights.
 */

// Variables default values
cabletie_width = 9;
cabletie_wrapping_diameter = 40;
cabletie_minimum_thickness = 1.2; // would be overrided if too large
label="";
label_font="Liberation Sans:style=Bold";

// FDM 3D printer parameters
nozzle_width = 0.4;
printer_tolerance = 0.2;

// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

module cabletie(w=cabletie_width,
                d=cabletie_wrapping_diameter,
                t=cabletie_minimum_thickness,
                l=label,
                nw=nozzle_width,
                pt=printer_tolerance) {

     // Funcions
     function cabletie_wrapping_circumference(d)
          = 3.14*d;
     function cabletie_steps_lenth(w, nw)
          = (w-2*nw)*cos(30);
     function cabletie_links_count(d, w, nw)
          = floor(cabletie_wrapping_circumference(d)/cabletie_steps_lenth(w, nw));
     function retainer_hole_length(w, nw)
          = cabletie_steps_lenth(w, nw)/3;
     function release_hole_length(w, nw)
          = cabletie_steps_lenth(w, nw);
     function cabletie_maximum_thickness(w, nw)
          = (cabletie_steps_lenth(w, nw)/3+nw)/tan(30)-(nw/sin(30)-nw);
     function cabletie_thickness(mini_thickness, maxi_thickness)
          = mini_thickness > maxi_thickness ? maxi_thickness : mini_thickness;
     function cabletie_lock_length()
          = cabletie_thickness(t, cabletie_maximum_thickness(w, nw))*8;
     function cabletie_lock_width()
          = cabletie_thickness(t, cabletie_maximum_thickness(w, nw))*4+release_hole_length(w, nw);

     // Generates the links
     module cabletie_links() {
          for (i = [0 : cabletie_steps_lenth(w, nw) : cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)-1)]) {
               translate([i, 0, 0]) {
                    // Shape of a regular links
                    polygon(points=[[0,0],
                                    [0,cabletie_steps_lenth(w, nw)/2],
                                    [cabletie_steps_lenth(w, nw),0],
                                    [0,-cabletie_steps_lenth(w, nw)/2]]);
               }
          }
          // Last link custom shape
          translate([cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)+1/2), 0, 0]) {
               circle(d = cabletie_steps_lenth(w, nw));
          }
          translate([cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)), -cabletie_steps_lenth(w, nw)/2, 0]) {
               square([cabletie_steps_lenth(w, nw)/2, cabletie_steps_lenth(w, nw)]);
          }
          // Connect all links
          translate([0, -(cabletie_steps_lenth(w, nw)/3)/2, 0]) {
               square([cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)), cabletie_steps_lenth(w, nw)/3]);
          }
     }

     // Generates the cabletie lock frame
     module cabletie_lock_boundary() {
          translate([-cabletie_lock_length(),
                     -cabletie_lock_width()/2,
                     0]) {
               square([cabletie_lock_length(),
                       cabletie_lock_width()]);
          }
     }

     // Generates the cabletie lock hole
     module cabletie_lock_hole() {
          union() {
               translate([-3/8*cabletie_lock_length(),
                          -release_hole_length(w, nw)/2-printer_tolerance,
                          0])
                    square([cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                            release_hole_length(w, nw)+2*printer_tolerance]);
               // retainer hole
               translate([-5/8*cabletie_lock_length(),
                          -retainer_hole_length(w, nw)/2-printer_tolerance,
                          0])
                    square([2/8*cabletie_lock_length(),
                            retainer_hole_length(w, nw)+2*printer_tolerance]);
          }
     }

     // Generates text
     module cabletie_text(l) {
          translate([-cabletie_lock_length(), 0, 0]) {
               resize([0, 0.7*cabletie_lock_width()], auto=true) {
                    text(l, valign = "center", halign = "right", font = label_font);
               }
          }
     }

     // Generates label boundary
     module cabletie_label_boundary(l) {
          minkowski() {
               resize([0, 0.7*cabletie_lock_width()])
                    hull() projection() translate([0, 1/2, 0]) rotate([90, 0, 0]) linear_extrude(1) cabletie_text(l);
               circle(d=0.3*cabletie_lock_width());
          }
     }
     // Main
     difference() {
          // Positive shapes
          linear_extrude(cabletie_thickness(t, cabletie_maximum_thickness(w, nw))) {
               offset(r = nw) {
                    union() {
                         cabletie_links();
                         hull() {
                              cabletie_lock_boundary();
                              cabletie_label_boundary(l);
                         }
                    }
               }
          }
          // Negative shapes
          union() {
               translate([0, 0, cabletie_thickness(t, cabletie_maximum_thickness(w, nw))/2]) {
                    linear_extrude(cabletie_thickness(t, cabletie_maximum_thickness(w, nw))/2) {
                         cabletie_text(l);
                    }
               }
               linear_extrude(cabletie_thickness(t, cabletie_maximum_thickness(w, nw))) {
                    offset(r = nw) {
                         cabletie_lock_hole();
                    }
               }
          }
     }
}

// Demo
//cabletie(6, 15, 1.0);
//translate([0, -12, 0]) cabletie(6, 20, 1.0);
//translate([0, -24, 0]) cabletie(6, 25, 1.0);
//
//translate([0, -40, 0]) cabletie(8, 20, 1.2);
//translate([0, -55, 0]) cabletie(8, 25, 1.2);
//translate([0, -70, 0]) cabletie(8, 30, 1.2);
//
//translate([0, -90, 0]) cabletie(10, 35, 1.4);
//translate([0, -108, 0]) cabletie(10, 45, 1.4);
//translate([0, -126, 0]) cabletie(10, 55, 1.4);
//
//translate([0, -150, 0]) cabletie(w=10, d=60, t=1.6, l="Label");
//translate([0, -170, 0]) cabletie(w=10, d=65, t=1.6, l="Cabletie");
//translate([0, -190, 0]) cabletie(w=10, d=70, t=1.6, l="OpenSCAD");

// All parameters demo
//cabletie(w=16, d=80, t=1.8, l="Demo", nw=0.6, pt=0.3);

// Customizer
cabletie();

