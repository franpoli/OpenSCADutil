/*
thumbdrive_housing.scad generates USB/thumb drive housing
GNU General Public License v3.0
Permissions of this strong copyleft license are conditioned on making available complete source
code of licensed works and modifications, which include larger works using a licensed work, under
the same license. Copyright and license notices must be preserved. Contributors provide an express
grant of patent rights.
*/

label="";
label_font="Liberation Sans:style=Bold";

key_bow = true; // [true|false]

usb_covered_length = 2.8;
usb_length = 14.8;
usb_width = 12.6;
usb_height = 4.6;

pcb_length = 29.9;
pcb_width = 14.0;

printer_tolerance = 0.2;
nozzle_width = 0.4;

/* [Hidden] */
// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

module thumbdrive_housing( l = label,
                           kb = key_bow,
                           uw = usb_width,
                           ul = usb_length,
                           uh = usb_height,
                           pw = pcb_width,
                           pl = pcb_length,
                           ucl = usb_covered_length,
                           tol = printer_tolerance,
                           nw = nozzle_width ) {

  function key_bow_size() = pw/3;

  module usb_area() {
    translate([-(pl+ul)/2, 0, 0]) {
      square(size = [ul, uw], center = true);
    }
  }

  module pcb_area() {
    square(size = [pl, pw], center = true);
  }

  module housing_cover() {
    difference() {
      translate([0, 0, -uh/2-ucl/4-tol]) hull() {
        translate([0, 0, ucl/8]) {
          linear_extrude(height = ucl/4, center = true, convexity = 10, twist = 0) {
            offset(r = ucl) square(size = [pl+tol, pw+tol], center = true);
            if (key_bow) translate([pl/2+tol+(key_bow_size()+ucl), 0, 0]) circle(r=key_bow_size()+ucl);
          }
        }
        translate([0, 0, -ucl/8]) {
          linear_extrude(height = ucl/4, center = true, convexity = 10, twist = 0) {
            offset(r = ucl-ucl/4) square(size = [pl+tol, pw+tol], center = true);
            if (key_bow) translate([pl/2+tol+(key_bow_size()+ucl), 0, 0]) circle(r=key_bow_size()+ucl-ucl/4);
          }
        }
      }
      translate([pl/2+tol+(key_bow_size()+ucl), 0, -uh/2-ucl/4-tol]) cylinder(h=ucl/2, r=key_bow_size(), center=true);
    }
  }

  module label(l) {
    mirror([1, 0, 0]) translate([0, 0, -5*ucl/4-tol/4]) {
      linear_extrude(height = ucl/4, center = true, convexity = 10, twist = 0) {
        resize([0.8*pl, 0.6*pw, 0], auto=true) {
          text(l, valign = "center", halign = "center", font = label_font);
        }
      }
    }
  }
  
  module frame() {
    linear_extrude(height = uh+2*tol, center = true, convexity = 10, twist = 0) {
      difference() {
        hull() {
          offset(r = ucl) square(size = [pl+tol, pw+tol], center = true);
          if (key_bow) translate([pl/2+tol+(key_bow_size()+ucl), 0, 0]) circle(r=key_bow_size()+ucl);
        }
        offset(r = tol) pcb_area();
        offset(r = tol) usb_area();
        if (key_bow) translate([pl/2+tol+(key_bow_size()+ucl), 0, 0]) circle(r=key_bow_size());
      }
    }
  }

  module print_settings() {
    perimeters = floor(ucl/nw/2);
    echo("SUGGESTED FDM PRINTER SETTINGS:");
    echo(nozzel_width=nw, number_of_perimeters=perimeters);
  }

  /* Main */
  // Housing box
  difference() {
    union() {
      frame();
      housing_cover();
    }
    label(l);
  }
    
  // Housing cover
  translate([0, (pw+2*ucl+tol)+5, 0]) housing_cover();

  /* Nude thumbrive space */
  if ($preview) #linear_extrude(height = uh, center = true, convexity = 10, twist = 0) {
    pcb_area();
    usb_area();
  }

  /* Printing suggested printer settings */
  print_settings();

};

// Customizer instantiation
thumbdrive_housing();
