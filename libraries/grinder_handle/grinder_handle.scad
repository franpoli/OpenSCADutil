include <BOSL2/std.scad>;

/* [Handle parameters] */
handle_grip_texture = "divex"; // ["divex", "dicav", "pyvex", "pycav", "none"]
fingers_guard_width = 16;
handle_minimal_diameter = 30;
handle_length = 100;
handle_cap_height = 5;

/* [Bolt dimension] */
bolt_screw_diameter = 10; // [8:1:12]
bolt_head_width = 15.3;
bolt_nominal_length = 100; // [50:1:120]
grinder_thread_length = 10;

/* [Printer settigs] */
nozzle_width = 0.4; // [0.2:0.1:0.8]
tolerance = 0.2; //[0.05:0.05:0.4]

/* [Hidden] */
bolt_head_diameter = bolt_head_width * sqrt(5)/2;
bolt_head_space_diameter = bolt_head_diameter + 2*tolerance;
bolt_thread_space_diameter = bolt_screw_diameter + 2*tolerance;
wall_thickness = ceil(2/nozzle_width) * nozzle_width;
handle_minimal_radius = handle_minimal_diameter/2;
guard_radius = handle_minimal_radius + fingers_guard_width;
base_radius = bolt_thread_space_diameter/2 + 2*wall_thickness;
hand_guard_sz = fingers_guard_width/2 + wall_thickness + (guard_radius - base_radius);
total_handle_length = hand_guard_sz + handle_length + handle_cap_height;
handle_with_max_factor = 1.25;
handle_with_mid_factor = 1.20;
handle_with_min_factor = 1.15;

// Default redering resolution
$fa = $preview ? 5 : 1; // default minimum facet angle
$fs = $preview ? 2 : 1; // default minimum facet size

module main() {
  difference() {
    // Grinder Handle
    hand_guard(anchor=BOT) position(TOP) handle(anchor=BOT)
      attach(TOP, BOT) cyl(h = handle_cap_height,
			   d = handle_minimal_diameter*handle_with_max_factor,
			   chamfer = 1);
    // Bolt
    zmove(-grinder_thread_length) {
      cyl(l = total_handle_length + grinder_thread_length + tolerance,
	  d = bolt_thread_space_diameter,
	  anchor=BOT, $fn=18)
	position(TOP) cyl(h = total_handle_length - bolt_nominal_length
			  + tolerance + grinder_thread_length,
			  d = bolt_head_space_diameter,
			  anchor=TOP, $fn=6);
    }
  }
}

// Attachable hand guard module on top and bottom
module hand_guard(s = [2*guard_radius, 2*guard_radius,
                       hand_guard_sz],
                  anchor = CENTER, spin = 0, orient = UP) {

  attachable(anchor, spin, orient, size = s) {
    // Center the handle end relative to the anchors
    zmove(s.z/2-fingers_guard_width/4) {
      // Handle end
      cyl(l = fingers_guard_width/2,
	  d = handle_minimal_diameter,
	  rounding1 = -fingers_guard_width/2) {
	// Guard ring
	attach(BOT, TOP) cyl(l = wall_thickness,
			     r = guard_radius,
			     chamfer2 = wall_thickness/2) {
	  // Attachment end
	  attach(BOT, TOP) cyl(h = guard_radius - base_radius,
			       r1 = bolt_thread_space_diameter/2 + 2*wall_thickness,
			       r2 = guard_radius);
	}
      }
    }
    children();
  }
}

// Attachable handle module on top and bottom
module handle(s = [handle_minimal_radius*handle_with_max_factor,
		   handle_minimal_radius*handle_with_max_factor, handle_length],
              anchor = CENTER, spin = 0, orient = UP) {
  
  // Local function, only visible inside this module
  function get_texture_params(texture) =
    texture == "divex" ? ["diamonds", true, [5,5], 0.4, "convex", undef, undef] :
    texture == "dicav" ? ["diamonds", true, [5,5], 0.4, "concave", undef, undef] :
    texture == "pyvex" ? ["pyramids", true, [4,4], 0.4, "convex", 1, 10] :
    texture == "pycav" ? ["pyramids", true, [5,5], 0.5, "concave", 1, 10] :
    [];

  bez = [[handle_minimal_radius, 0],
	 [handle_minimal_radius*handle_with_min_factor, handle_length*0.4],
	 [handle_minimal_radius*handle_with_max_factor, handle_length*0.6],
	 [handle_minimal_radius*handle_with_mid_factor, handle_length]];
  
  closed = bezpath_close_to_axis(bez, axis = "Y");
  path = bezpath_curve(closed, N=3);

  attachable(anchor, spin, orient, size = s) {
    zmove(-s.z/2) {params = get_texture_params(handle_grip_texture);
      if (len(params) == 0) {
	// Whithout texture texture call rotate_sweep with minimal arguments
	rotate_sweep(path, 360);
      } else {
	// With texture call rotate_sweep with all parameters
	rotate_sweep(path, 360,
		     texture=params[0], caps=params[1], tex_size=params[2],
		     tex_taper=params[3], style=params[4],
		     tex_depth=params[5], convexity=params[6]);
      }
    }
    children();
  }
}

main();
