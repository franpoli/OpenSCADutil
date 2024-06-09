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

key_bow = "N"; //[N:None, T:Tiny, S:Small, M:Medium, L:Large]
interlocking = false; //[true, false]

usb_covered_length = 2.8;
usb_length = 14.8;
usb_width = 12.6;
usb_height = 4.6;

pcb_length = 29.9;
pcb_width = 14.0;

printer_tolerance = 0.2;
nozzle_width = 0.4;
layer_height = 0.2;

/* [Hidden] */
// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

// oversize for preview rendering of negative shapes
oversize = 0.1;

module thumbdrive_housing( l = label,
                           kb = key_bow,
                           il = interlocking,
                           uw = usb_width,
                           ul = usb_length,
                           uh = usb_height,
                           pw = pcb_width,
                           pl = pcb_length,
                           ucl = usb_covered_length,
                           tol = printer_tolerance,
                           nw = nozzle_width,
                           lh = layer_height ) {

  function key_bow_hole_size()
    = ((kb == "S") || (kb == "Small")) ? pw/3
    : ((kb == "M") || (kb == "Medium")) ? pw/2
    : ((kb == "L") || (kb == "Large")) ? 3*pw/4
    : 0; // Default value 0 for N, None or anything else
  
  function chamfer() = ucl/4;
  
  module add_key_bow(chamfer = 0) {
    if ((kb != "N") && (kb != "None")) {
      translate([pl/2+tol+(key_bow_hole_size()+ucl), 0, 0]) {
        circle(r=key_bow_hole_size()+ucl-chamfer);
      }
    }
  }
  
  module substract_key_bow_hole() {
    if ((kb != "N") && (kb != "None")) {
      linear_extrude(height = uh+2*tol+ucl+oversize, center = true, convexity = 10, twist = 0) {
        translate([pl/2+tol+(key_bow_hole_size()+ucl), 0, 0]) {
          circle(r=key_bow_hole_size());
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
  
  module extrude(size_h) {
    linear_extrude(height = size_h, center = true, convexity = 10, twist = 0) {
      children();
    }
  }

  module thumbdrive_shape(size_h, size_o, size_x, size_y, size_r) {
    extrude(size_h) {
      offset(r = size_o) {
        square(size = [size_x, size_y], center = true);
      }
      add_key_bow(size_r);
    }
  }

  module housing_cover() {
    translate([0, 0, -uh/2-chamfer()-tol]) {
      hull() {
        translate([0, 0, chamfer()/2]) {
          thumbdrive_shape(chamfer(), ucl, pl+tol, pw+tol, 0);
        }
        translate([0, 0, -chamfer()/2]) {
          thumbdrive_shape(chamfer(), ucl-chamfer(), pl+tol, pw+tol, chamfer());
        }
      }
    }
  }

  module label(l) {
    mirror([1, 0, 0]) {
      translate([0, 0, -5*chamfer()-tol/4-oversize/2]) {
        extrude(chamfer()) {
          resize([0.8*pl, 0.6*pw, 0], auto=true) {
            text(l, valign = "center", halign = "center", font = label_font);
          }
        }
      }
    }
  }
  
  module frame() {
    difference() {
      hull() thumbdrive_shape(uh+2*tol, ucl, pl+tol, pw+tol, 0);
      extrude(uh+2*tol+oversize) {
        offset(r = tol) pcb_area();
        offset(r = tol) usb_area();
      }
    }
  }
  
  module print_settings() {
    perimeters = floor(ucl/nw/2);
    echo("SUGGESTED FDM PRINTER SETTINGS:");
    echo(nozzel_width=nw, layer_height=lh, number_of_perimeters=perimeters);
  }
  
  // Main
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
    translate([0, (pw > 2*key_bow_hole_size()) ? pw+2*(ucl+tol) + dist : 2*key_bow_hole_size()+2*(ucl+tol) + dist, 0]) {
      union() {
        difference() {
          housing_cover();
          substract_key_bow_hole();
        }
        if (il) {
          translate([0, 0, -uh/2]) {
            extrude(2*lh) difference() {
              pcb_area();
              offset(r = -2*nw) pcb_area();
            }
          }
        }
      }
    }
    
    // Nude USB drive
    if ($preview) {
      color("Green", 0.5) {
        extrude(uh) {
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
