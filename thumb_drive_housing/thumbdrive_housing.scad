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

key_bow = "N"; //[N:None, S:Small, M:Medium, L:Large]

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

// oversize for preview rendering
oversize = 0.1;

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

  function key_bow_size()
    = ((kb == "S") || (kb == "Small")) ? pw/3
    : ((kb == "M") || (kb == "Medium")) ? pw/2
    : ((kb == "L") || (kb == "Medium")) ? 3*pw/4
    : 0; // None default value

  function chamfer() = ucl/4;

  module add_key_bow(chamfer = 0) {
    if ((kb != "N") && (kb != "None")) {
      translate([pl/2+tol+(key_bow_size()+ucl), 0, 0]) {
        circle(r=key_bow_size()+ucl-chamfer);
      }
    }
  }

  module substract_key_bow_hole() {
    if ((kb != "N") && (kb != "None")) {
      linear_extrude(height = uh+2*tol+ucl+oversize, center = true, convexity = 10, twist = 0) {
        translate([pl/2+tol+(key_bow_size()+ucl), 0, 0]) {
          circle(r=key_bow_size());
        }
      }
    }
  }

  module usb_area() {
    translate([-(pl+ul)/2, 0, 0]) {
      square(size = [ul, uw], center = true);
    }
  }

  module pcb_area() {
    square(size = [pl, pw], center = true);
  }

  module housing_cover() {
    translate([0, 0, -uh/2-chamfer()-tol]) {
      hull() {
        translate([0, 0, chamfer()/2]) {
          linear_extrude(height = chamfer(), center = true, convexity = 10, twist = 0) {
            offset(r = ucl) {
              square(size = [pl+tol, pw+tol], center = true);
            }
            add_key_bow();
          }
        }
        translate([0, 0, -chamfer()/2]) {
          linear_extrude(height = chamfer(), center = true, convexity = 10, twist = 0) {
            offset(r = ucl-chamfer()) {
              square(size = [pl+tol, pw+tol], center = true);
            }
            add_key_bow(chamfer());
          }
        }
      }
    }
  }

  module label(l) {
    mirror([1, 0, 0]) {
      translate([0, 0, -5*chamfer()-tol/4-oversize/2]) {
        linear_extrude(height = chamfer()+oversize, center = true, convexity = 10, twist = 0) {
          resize([0.8*pl, 0.6*pw, 0], auto=true) {
            text(l, valign = "center", halign = "center", font = label_font);
          }
        }
      }
    }
  }
  
  module frame() {
    linear_extrude(height = uh+2*tol, center = true, convexity = 10, twist = 0) {
      difference() {
        hull() {
          offset(r = ucl) {
            square(size = [pl+tol, pw+tol], center = true);
          }
          add_key_bow();
        }
        offset(r = tol) pcb_area();
        offset(r = tol) usb_area();
      }
    }
  }

  module print_settings() {
    perimeters = floor(ucl/nw/2);
    echo("SUGGESTED FDM PRINTER SETTINGS:");
    echo(nozzel_width=nw, number_of_perimeters=perimeters);
  }

  module thumdrive() {
    // Distance between cover and PCB holder
    dist = 5;
    // Housing
    difference() {
      union() {
        frame();
        housing_cover();
      }
      label(l);
      substract_key_bow_hole();
    }
    
    // Housing cover
    //translate([0, (pl+2*ucl+tol)+key_bow_size()/2, 0]) {
    translate([0, (pw > 2*key_bow_size()) ? pw+2*(ucl+tol) + dist : 2*key_bow_size()+2*(ucl+tol) + dist , 0]) {
      difference() {
        housing_cover();
        substract_key_bow_hole();
      }
    }

    // Nude USB drive
    if ($preview) {
      color("Green", 0.5) {
        linear_extrude(height = uh, center = true, convexity = 10, twist = 0) {
          pcb_area();
          usb_area();
        }
      }
    }

    // Print suggested printer settings */
    print_settings();
  }
  thumdrive();
};

// Customizer instantiation
thumbdrive_housing();
