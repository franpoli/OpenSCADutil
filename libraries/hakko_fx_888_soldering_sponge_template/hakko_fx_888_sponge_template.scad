/*
Generate a Hakko FX-888 soldering sponge template to be printed on FDM 3D printer 

GNU General Public License v3.0
Permissions of this strong copyleft license are conditioned on making available complete source
code of licensed works and modifications, which include larger works using a licensed work, under
the same license. Copyright and license notices must be preserved. Contributors provide an express
grant of patent rights.
*/

// Variables default values
scaling_factor = 100; // [1:100]
layer_heigth = 0.2;
number_of_layers = 4;
label = false;
label_font="Liberation Sans:style=Bold";

/* [Hidden] */
width = 68;
length = 52;
filet = 5;
radius = 33;
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

module fx888_sponge_template( sf = scaling_factor,
                              lh = layer_heigth,
                              nl = number_of_layers,
                              lb = label ) {

  module sponge_surface() {
    hull() {
      for (i = [0:1:1]) {
        mirror([i, 0, 0]) {
          translate([width/2-filet, 0, 0]) {
            circle(r = filet);
          }
        }
      }
      difference() {
        translate([0, length-radius-filet, 0]) {
          circle(r = radius);
        }
        translate([0, -radius/2, 0]) {
          square([width, radius], true);
        }
      }
    }
  }

  module sponge_holes() {
    for (j = [0:1]) {
      mirror([j, 0, 0]) hull() for (i = [1:3:4]) {
        translate([radius/4, radius/i, 0]) circle(d = filet/2);
      }
    }
  }

  module scalling_factor_label() {
    preview_offset = 0.1;
    translate([0, 0, (ceil(nl/2)*lh+preview_offset)/2]) {
      linear_extrude(height = ceil(nl/2)*lh+preview_offset, center = true, convexity = 10, twist = 0) {
        scale([sf/100, sf/100, 0]) rotate([0, 0, 180]) resize([0, filet], auto=true) {
          text(str(sf, "%"), valign = "center", halign = "center", font = label_font);
        }
      }
    }
  }

  // Main
  difference() {
    linear_extrude(height = nl*lh, center = true, convexity = 10, twist = 0) {
     scale([sf/100, sf/100, 0])  difference() {
        sponge_surface();
        sponge_holes();
      }
    }
    if (lb) scalling_factor_label();
  }
}

// Customizer instance
fx888_sponge_template();
