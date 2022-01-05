/*
 * escutcheon.scad - split ring escutcheons to cover jagged holes or open spaces around radiator pipes.
 * by François Polito
 * created 2021-12-20
 * GNU General Public License v3.0
 * Permissions of this strong copyleft license are conditioned on making available complete source
 * code of licensed works and modifications, which include larger works using a licensed work, under
 * the same license. Copyright and license notices must be preserved. Contributors provide an express
 * grant of patent rights.
 */

// Usage
// estanchon(h = height, d = diameter, type_of_angle = filet);
// estanchon(h = height, d = diameter, s = separation, e = decoration);
// estanchon(h = height, d = diameter, s = separation, e = decoration, nw=nozzle_width, pt=printer_tolerance);

// Variables default values
escutcheon_height = 6;
escutcheon_width = 12;
escutcheon_hole_diameter = 18;
separation_between_pipes = 40; // from pipe center to pipe center
edge = "filet"; // ["none"|"filet"|"chamfer"]

// FDM 3D printer parameters
nozzle_width = 0.4; 
printer_tolerance = 0.2;

// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

// Functions
function is_two_pipes_escutcheon(d=escutcheon_hole_diameter, s=separation_between_pipes) = s > d ? "true" : "false";
function escutcheon_length(d=escutcheon_hole_diameter, w=escutcheon_width, s=separation_between_pipes) = is_two_pipes_escutcheon(d, s) ? 2*w+d+s : 2*w+d;

// Positioning the edge
module translate_angle(x, y, z=0) {
     translate([x, y, z]) children();
}

// Generates attachments for additions or substractions
module escutcheon_attachment(h=escutcheon_height, w=escutcheon_width, nw=nozzle_width, pt=printer_tolerance, tolerance=false) { // set the tolerance to true to increase the attachment size by the printer tolerance value
     linear_extrude(height=h, convexity=5) {
          difference() {
               union() {
                    offset(-1) offset(1+(tolerance == false ? 0 : pt)) {
                         translate([0, -pt/2, 0]) {
                              for (i = [0:1:1]) mirror([i*1, 0, 0]) {
                                   polygon([[0, pt],
                                            [-w/3, pt],
                                            [-w/6, pt],
                                            [-w/8, -pt],
                                            [-w/4+pt/2, -w/4+pt],
                                            [-w/4+pt, -w/4],
                                            [0, -w/4]]);
                              }
                         }
                    }
               }
               translate([-pt-w/6, pt/2, 0]) square([2*pt+w/3, pt]);
          }
     }
}

module place_escutcheon_attachments(w=escutcheon_width, d=escutcheon_hole_diameter, s=separation_between_pipes) {
     if (is_two_pipes_escutcheon(d, s) == "false") {
          for (i = [0:1:1]) mirror([i*1, 0, 0]) translate([(d+w)/2, 0, 0]) children();
     }
     else if (w > (s-d)) {
          //for (i = [0:1:1]) mirror([i*1, 0, 0]) translate([(s-d)/2+d+w/2, 0, 0]) children();
          for (i = [0:1:1]) mirror([i*1, 0, 0]) translate([(s+d+w)/2, 0, 0]) children();
     }
     else {
          //for (i = [0:1:1]) mirror([i*1, 0, 0]) translate([(s-d)/2+d+w/2, 0, 0]) children();
          for (i = [0:1:1]) mirror([i*1, 0, 0]) translate([(s+d+w)/2, 0, 0]) children();
          children();
     }
}

// Generates a single pipe estanchon template with edge decoration
module escutcheon_template(h=escutcheon_height, w=escutcheon_width, d=escutcheon_hole_diameter, e=edge) {
     rotate_extrude(convexity = 10) {
          union() {
               square([d/2+w, 3/4*h]);
               translate([0, 3/4*h , 0]){
                    square([d/2+w-1/4*h, 1/4*h]);
               }
               if (e == "filet") {
                    translate_angle(x=d/2+w-1/4*h, y=3/4*h) circle(r=1/4*h);
               }
               else if (e == "chamfer") {
                    translate_angle(x=d/2+w-1/4*h, y=3/4*h) polygon([[0,0], [0, 1/4*h], [1/4*h, 0]]);
               }
               else { // none (or any invalid value)
                    translate_angle(x=d/2+w-1/4*h, y=3/4*h) square([1/4*h, 1/4*h]);
               }
          }
     }
}

// Generate final estruchon piece
module escutcheon(h=escutcheon_height, w=escutcheon_width, d=escutcheon_hole_diameter, s=separation_between_pipes, e=edge, nw=nozzle_width, pt=printer_tolerance) {
     // Warning messsage!
     if ((is_two_pipes_escutcheon(d, s) != "true") && (s > 0)) {echo("WARNING: not enough distance between pipes, generating single pipe escutcheon");}
     if (is_two_pipes_escutcheon(d, s) == "true") {
          union() {
               difference() {
                    hull() {
                         // move the template from x axis and mirror a copy of it on x axis
                         for (i = [0:1:1]) mirror([i*1, 0, 0]) {
                              translate([-s/2, 0, 0]) escutcheon_template(h, w, d, e);
                         }
                    }
                    union() {
                         for (i = [0:1:1]) mirror([i*1, 0, 0]) {
                              translate([-s/2, 0, 0]) cylinder(h=h, d=d);
                         }
                         translate([-escutcheon_length(d, w, s)/2, -pt/2, 0]) cube([escutcheon_length(d, w, s), pt, h]);
                    }
                    place_escutcheon_attachments(w, d, s) escutcheon_attachment(h, w, nw, pt, tolerance=true);
               }
               place_escutcheon_attachments(w, d, s) escutcheon_attachment(h, w, nw, pt, tolerance=false);
          }
     }
     else {
          union() {
               difference() {
                    escutcheon_template(h, w, d, e);
                    cylinder(h=h, d=d);
                    place_escutcheon_attachments(w, d, s) escutcheon_attachment(h, w, nw, pt, tolerance=true);
                    translate([-escutcheon_length(d, w, s)/2, -pt/2, 0]) cube([escutcheon_length(d, w, s), pt, h]);
               }
               place_escutcheon_attachments(w, d, s) escutcheon_attachment(h, w, nw, pt, tolerance=false);
          }
     }
}

// DEMO
//escutcheon();
//translate([0, 50, 0]) escutcheon(s=36, e="chamfer");
//translate([0, 90, 0]) escutcheon(h=4, w=6, d=16, s=24, e="none", nw=0.2, pt=0.2);
//translate([0, 125, 0]) escutcheon(h=3, w=8, d=10, s=0, e="chamfer", nw=0.6, pt=0.3);
