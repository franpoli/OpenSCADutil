// Teardrop Airtag Keyring Case

include <apple_airtag.scad>;
include <extra.scad>;

/* [Parameters] */
thickness = 5; // [5:0.2:6.4]
printer_nozzel_width = 0.40;    // [0.10: 0.05: 0.60]
printer_mimimum_perimeters = 2; // [2:1:6]
printer_tolerance = 0.20;       // [0.05: 0.05: 0.30]

/* [Hidden] */
radius1 = get_airtag_width();
echo("radius1", radius1);
radius2 = get_airtag_width()/2;
echo("radius2", radius2);
radius3 = (radius1/2) - 11;
echo("radius3", radius3);
lock_position = get_airtag_h_seg_y_pos();
lock_height = get_airtag_v_seg_length();

// Default redering resolution
$fa = $preview ? 5 : 2.0; // default minimum facet angle
$fs = $preview ? 1 : 0.5; // default minimum facet size

module teardrop_plan() {
  union() {
    circle_sector(radius2, 180, 360);
    large_circle_sector();
    mirror([1, 0]) large_circle_sector();
  }

  module large_circle_sector() {
    translate([-radius2, 0, 0]) circle_sector(radius1, 0, 60);
  }
}

module keyring_slot(coef = 1.4) {
  linear_extrude(coef*thickness) {
    translate([0, radius2+radius3+printer_mimimum_perimeters*printer_nozzel_width])
      circle(radius3 - printer_mimimum_perimeters*printer_nozzel_width);
    translate([0,coef*radius2/2]) square([1,coef*radius2],center=true);
  }
}

module main() {
  difference() {
    translate([0, 0, lock_position-lock_height]) {
      bulge_extrude(thickness, thickness/6, steps=abs(thickness))
	offset(r = printer_mimimum_perimeters * printer_nozzel_width) teardrop_plan();
    }
    airtag(printer_tolerance, false);
    keyring_slot();
  } 
  if ($preview) debug_airtag(printer_tolerance, false);
}

main();
