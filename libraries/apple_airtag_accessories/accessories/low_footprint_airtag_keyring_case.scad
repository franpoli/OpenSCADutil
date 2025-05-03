// Low Footprint Airtag Keyring Case

include <apple_airtag.scad>;
include <extra.scad>;

/* [Airtag Keyring Case Parameters] */
thickness = 5; // [5:0.2:6.4]
key_hole_radius = 2.5; // [1.5:0.2:4]

/* [Printer Parameters] */
printer_nozzel_width = 0.40;    // [0.10: 0.05: 0.60]
printer_layer_height = 0.20;    // [0.10: 0.05: 0.25]
printer_mimimum_perimeters = 2; // [2:1:6]
printer_tolerance = 0.20;       // [0.05: 0.05: 0.30]

// Default redering resolution
$fa = $preview ? 5 : 2.0; // default minimum facet angle
$fs = $preview ? 1 : 0.5; // default minimum facet size

/* [Hidden] */
main_radius = get_airtag_width() / 2;
minimum_wall_thickness = printer_nozzel_width * 3;
bulge_layer_height = 0.01;
airtag_z_shift = get_airtag_v_seg_length() - get_airtag_h_seg_y_pos();

module airtag_keyring_plan(shell = false, key_slot = false) {
  module shapes(_key_slot = key_slot) {
    union() {
      if (!_key_slot) circle(r = main_radius);
      translate([0, main_radius, 0])
	for (i = [0:1])
	  mirror([0, i]) translate([0, key_hole_radius, 0])
	    if (i == 0) circle(r = key_hole_radius);
	    else rotate([0, 0, 30]) circle(r = key_hole_radius, $fn = 3);
    }
  }
  module boundary_shapes() {
    offset(delta = main_radius/2) translate([-main_radius, -main_radius, 0])
      square(size = [2 * main_radius,
		     2 * (main_radius + key_hole_radius)]);
  }

  module plan() {
    difference() {
      offset(delta = -printer_nozzel_width) boundary_shapes();
      fillet_reflex_angles(2*printer_nozzel_width)
	difference() { boundary_shapes(); shapes(_key_slot = key_slot); };
    }
  }

  if (shell) {
    hull() offset(r = printer_mimimum_perimeters * printer_nozzel_width) plan();
  } else { plan(); };
}

module main() {
  difference() {
    bulge_extrude(thickness, thickness/6, steps=abs(thickness))
      airtag_keyring_plan(shell = true, key_slot = false);
    translate([0, 0, airtag_z_shift]) airtag(printer_tolerance, false);
    translate([0, 0, -printer_layer_height/2])
      linear_extrude(thickness + printer_layer_height)
      airtag_keyring_plan(shell = false, key_slot = true);
  }
  if ($preview)
    translate([0, 0, airtag_z_shift])
      debug_airtag(printer_tolerance, false, false);
}

main();
