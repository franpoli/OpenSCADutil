/* Apple AirTag
 * Can be used to create Apple AirTag accessories
 */

include <apple_airtag_data.scad>;

module airtag(clearance = 0, center = true) {
  rotate_extrude(convexity = 10)
    airtag_profile(clearance, center);
}

module airtag_profile(clearance = 0, center = true) {
  clr_tolrance = 1.1 * clearance;
  module shift_clearance() {
    shift_y = (get_airtag_height()/2);
    translate([0, center ? -shift_y : 0, 0])
      offset(delta = clearance) polygon(points = AIRTAG_PTS);
  }
  // Trimming offset negative X
  difference() {
    shift_clearance();
    translate([-clr_tolrance, -clr_tolrance, 0])
      square(size = [clr_tolrance, get_airtag_height()+2*clr_tolrance]);
  }
}

module debug_airtag(clearance = 0, center = true, boundary_box = false) {
  S = get_airtag_instance_size(clearance = clearance);
  airtag(center = center);
  difference() {
    color("red", 0.5) airtag(center = center, clearance = clearance );
    airtag_cut();
  }

  if (boundary_box) {
    translate([S[0]/2, 0, 0])
      scale([2, 1, 1]) %airtag_cut();
  }
  
  module airtag_cut() {
    translate([-S[0]/4, 0, center ? 0 :
	       S[2]/2-clearance])
      cube(size = [S[0]/2, S[1], S[2]], center = true);
  }
}

// Usage:
//airtag(0, false);               // default: no clearance, center true
//airtag(0.20, false);             // example: +0.2 mm clearance
//debug_airtag(0.3, false);       // default: display half the envelope 
//debug_airtag(0.20, false, true); // display also boundary box
