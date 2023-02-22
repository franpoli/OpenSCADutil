/*
escutcheon.scad - split ring escutcheons to cover jagged holes or open spaces around radiator pipes.

GNU General Public License v3.0
Permissions of this strong copyleft license are conditioned on making available complete source
code of licensed works and modifications, which include larger works using a licensed work, under
the same license. Copyright and license notices must be preserved. Contributors provide an express
grant of patent rights.
 */

// Usage
// estanchon(h = height, d = diameter, e = decoration);
// estanchon(h = height, d = diameter, s = separation, e = decoration);
// estanchon(h = height, d = diameter, s = separation, e = decoration, nw = nozzle_width, pt = printer_tolerance);

// Variables default values
escutcheon_height = 6;
escutcheon_width = 12;
escutcheon_hole_diameter = 18;
separation_between_pipes = 40; // from pipe center to pipe center
edge = "filet"; // ["none","filet","chamfer"]
parts = "both"; // ["both","male","female"]

// FDM 3D printer parameters
nozzle_width = 0.4; 
printer_tolerance = 0.2;

// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

// Generate final estruchon piece
module escutcheon(
     h=escutcheon_height,
     w=escutcheon_width,
     d=escutcheon_hole_diameter,
     s=separation_between_pipes,
     e=edge,
     nw=nozzle_width,
     pt=printer_tolerance,
     p=parts) {

     // Functions
     function is_two_pipes_escutcheon(d=escutcheon_hole_diameter, s=separation_between_pipes) = s > d ? "true" : "false";
     function escutcheon_length(d=escutcheon_hole_diameter, w=escutcheon_width, s=separation_between_pipes) = is_two_pipes_escutcheon(d, s) ? 2*w+d+s : 2*w+d;
     function estutcheon_template_angle(p=parts) = p == "male" ? 180 : p == "female" ? -180 : 360;
     function bevel(w, h) = h/4 < w/6 ? h/4 : w/6;
     
     // Positioning the edge
     module translate_angle(x, y, z=0) {
          translate([x, y, z]) children();
     }
     
     // Generates attachments for additions or substractions
     module escutcheon_attachment(h=escutcheon_height, w=escutcheon_width, nw=nozzle_width, pt=printer_tolerance, tolerance=false) {
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
     
     // Positions attachments where they might be needed
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
     module escutcheon_template(h=escutcheon_height, w=escutcheon_width, d=escutcheon_hole_diameter, e=edge, p=parts) {
          rotate_extrude(angle = estutcheon_template_angle(p), convexity = 10) {
               union() {
                    square([d/2+w, h-bevel(w, h)]);
                    translate([0, h-bevel(w, h), 0]){
                         square([d/2+w-bevel(w, h), bevel(w, h)]);
                    }
                    if (e == "filet") {
                         translate_angle(x=d/2+w-bevel(w, h), y=h-bevel(w, h)) circle(r=bevel(w, h));
                    }
                    else if (e == "chamfer") {
                         translate_angle(x=d/2+w-bevel(w, h), y=h-bevel(w, h)) polygon([[0,0], [0, bevel(w, h)], [bevel(w, h), 0]]);
                    }
                    else { // none (or any invalid value)
                         translate_angle(x=d/2+w-bevel(w, h), y=h-bevel(w, h)) square([bevel(w, h), bevel(w, h)]);
                    }
               }
          }
     }

     // MAIN
     // Warning messsage!
     if ((is_two_pipes_escutcheon(d, s) != "true") && (s > 0)) {echo("WARNING: not enough distance between pipes, generating single pipe escutcheon");}
     if (is_two_pipes_escutcheon(d, s) == "true") {
          union() {
               difference() {
                    hull() {
                         // move the template from x axis and mirror a copy of it on x axis
                         for (i = [0:1:1]) mirror([i*1, 0, 0]) {
                              translate([-s/2, 0, 0]) escutcheon_template(h, w, d, e, p);
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
               if (p != "female") {
                    place_escutcheon_attachments(w, d, s) escutcheon_attachment(h, w, nw, pt, tolerance=false);
               }
          }
     }
     else {
          union() {
               difference() {
                    escutcheon_template(h, w, d, e, p);
                    cylinder(h=h, d=d);
                    place_escutcheon_attachments(w, d, s) escutcheon_attachment(h, w, nw, pt, tolerance=true);
                    translate([-escutcheon_length(d, w, s)/2, -pt/2, 0]) cube([escutcheon_length(d, w, s), pt, h]);
               }
               if (p != "female") {
                    place_escutcheon_attachments(w, d, s) escutcheon_attachment(h, w, nw, pt, tolerance=false);
               }
          }
     }
}

// DEMO
//translate([0, -60, 0]) escutcheon(p="female");
//translate([0, -50, 0]) escutcheon(p="male");
//escutcheon(6, 12, 18, 40);
//translate([0, 48, 0]) escutcheon(s=36, e="chamfer");
//translate([0, 90, 0]) escutcheon(h=4, w=6, d=16, s=24, e="none", nw=0.2, pt=0.2);
//translate([0, 125, 0]) escutcheon(h=3, w=8, d=10, s=0, e="chamfer", nw=0.6, pt=0.3);

// CUSTOMIZER
escutcheon();
