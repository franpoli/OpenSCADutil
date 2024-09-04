/*
pipe_locks_generator.scad

This OpenSCAD script generates customizable locking mechanisms for
pipes and tubes of various sizes. It includes three main components:

- Fixed base lock
- Threaded collar
- Threaded lid

These parts are designed to seal tubular structures, making them
ideal for creating recipients or containers.
*/


/* [Part selector] */
part_options = "Base"; // [Base, Collar, Lid]

/* [Main dimensions] */
outer_diameter = 100.0;
thickness = 2.8;
clearance = 0.2;
thread_heigth = 10;

/* [Curled pattern options] */
curled_pattern = "Medium"; // [Strong, Medium, Light, None]

/* [Printer settings] */
nozzle_width = 0.40; // [0.20, 0.40, 0.50, 0.60, 0.80]
printer_tolerance = 0.2; // [0.05,0.010,0.15,0.20,0.25,0.30,0.35,0.40]

/* [Hidden] */
inner_diameter = outer_diameter-2*thickness-clearance-printer_tolerance;


// Default redering resolution
$fa = $preview ? 5.0 : 2.0; // default minimum facet angle
$fs = $preview ? 2.0 : 1.0; // default minimum facet size
$fn = $preview ? 50.0 : 100.0; // default number of fragments

// Functions
function thread_diameter(is_external) = is_external ? 
  (inner_diameter-2*thickness) : 
  (inner_diameter-2*thickness-2*(printer_tolerance+clearance));

function chamfer_positon(is_external) = is_external ?
  -2*nozzle_width :
  -2*nozzle_width-sqrt(2)*thickness;

function curl_option(option) = (option == "Strong") ?
  1/2 : (option == "Medium") ?
  1/3 : (option == "Light") ?
  1/4 : 0;

// Permanent Bottom Lock
module fixed_base_lock() {
  union() {
    cylinder(h = thickness/2,
             d2 = outer_diameter,
             d1 = outer_diameter - thickness);
    translate([0, 0, thickness/2]) cylinder(h = thickness/2,
                                            d = outer_diameter);
    translate([0, 0, thickness]) {
      difference() {
        cylinder(h = 2*thickness,
                 d = inner_diameter);
        translate([0, 0, 2*nozzle_width]) {
          cylinder(h = 2*(thickness),
                   d2 = inner_diameter,
                   d1 = inner_diameter-4*thickness);
        }
      }
    }
  }
}

// Threaded Locking Mechanism
module threaded_collar() {
  difference() {
    union() {
      cylinder(h = thread_heigth,
               d = inner_diameter);
      translate([0, 0, thread_heigth-thickness/2])
      cylinder(h = thickness/2,
               d = outer_diameter);
    }
    thread(true);
  }
}

module locking_lid() {
  difference() {
    thread(false);
  }
  difference() {
    union() {
      translate([0, 0, thread_heigth]) {
        cylinder(h = thread_heigth-thickness,
                 d = outer_diameter);
        translate([0, 0, thread_heigth-thickness]) {
          cylinder(h = thickness/2,
                   d1 = outer_diameter,
                   d2 = outer_diameter-thickness);
        }
      }
    }
    curl();
  }
}

// Thread
module thread(is_external = true) {

  module thread_chamfer(is_external) {
    translate([0, 0, chamfer_positon(is_external)]) {
      rotate_extrude() {
        polygon([[0, 0], [inner_diameter/2, 0], [0, inner_diameter/2]]);
      }
    }
  }
  
  difference() {
    union() {
      linear_extrude(height = thread_heigth+0.01, // 0.01 diff. preview fix
                     convexity = 5,
                     twist = -720) {
        translate([thickness/4, 0, 0]) {
          circle(d = thread_diameter(is_external));
        }
      }
      if (is_external) {
        thread_chamfer(true);
      }
    }
    if (!is_external) {
      thread_chamfer(false);
    }
  }
}

// Curled pattern
module curl(diameter = outer_diameter,
            deepness = curl_option(curled_pattern)*thickness,
            divisor = 72) {
  translate([0, 0, thread_heigth]) {
    for (i = [-1:2:1]) {
      linear_extrude(height = thread_heigth,
                     convexity = 5,
                     twist = i*10) {
        for (i = [0: 360/divisor:360-360/divisor]) {
          rotate([0, 0, i]) {
            translate([-outer_diameter/2, 0, 0]) {
              circle(r = deepness, $fn = 3);
            }
          }
        }
      }
    }
  }
}

// Main (customizer part options)
// Re-orient parts for 3D pinting when needed
if (part_options == "Base") {
    fixed_base_lock();
} else if (part_options == "Collar") {
  translate([0, 0, thread_heigth]) {
    rotate([180, 0, 0]) {
      threaded_collar();
    }
  }
} else if (part_options == "Lid") {
  translate([0, 0, 2*thread_heigth-thickness/2])
  rotate([180, 0, 0]) {
    locking_lid();
  }
}
