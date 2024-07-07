/*
OpenSCAD Reusable Modules and Function Library

This library contains a collection of reusable modules and functions that can be used in
various OpenSCAD projects. The modules are designed to perform common tasks, such as
creating geometric shapes, transformations, and other useful operations. Each module is
self-contained and can be easily integrated into other OpenSCAD scripts.
*/

/* 2D */

// Circle sector (2D) given an angle from 0 ecluded to 360 included: angle ∈ ] 0; 360 ]
module circle_sector(radius, start_angle, end_angle) {
  
  module sector_less_or_equal_to_90_degrees(radius, start_angle, end_angle) {
    // Calculate the arc height based on central angle and radius (Sagitta formula)
    segment_height = radius * (2 * sin(abs(end_angle - start_angle) / 2));

    intersection() {
      circle(radius);
      rotate(start_angle) {
        polygon(points = [[0, 0],
                          [radius + segment_height, 0],
                          [(radius + segment_height) * cos(end_angle - start_angle),
                           (radius + segment_height) * sin(end_angle - start_angle)]]);
      }
    }
  }
  
  // Module entry point
  if ((end_angle - start_angle) > 0 && (end_angle - start_angle) <= 360) {
    number_of_quadrants = ceil((end_angle - start_angle) / 90);
    union() {
      for (i = [0:number_of_quadrants-1]) {
        segment_start_angle = start_angle + i * 90;
        segment_end_angle = min(start_angle + (i + 1) * 90, end_angle);
        
        rotate([0, 0, segment_start_angle]) {
          sector_less_or_equal_to_90_degrees(radius,
                                             0,
                                             segment_end_angle - segment_start_angle);
        }
      }
    }
  } else {
    assert(false, "Invalid angle. Use angle from 0 excluded to 360 included.");
  }
}

/// isosceles_trapezium(base1, base2, height)
/// Module to create an isosceles trapezium with optional centering.
/// Parameters:
/// - base1 or b1: Length of the bottom base (default 0).
/// - base2 or b2: Length of the top base (default 0).
/// - height or h: Height of the trapezium (default 0).
/// - center: Boolean to center the trapezium on the axes (default false).
///
/// Usage examples:
/// - Positional arguments:
///   isosceles_trapezium(10, 5, 6, center=true);
///
/// - Named parameters (short names):
///   isosceles_trapezium(b1=10, b2=5, h=6, center=true);
///
/// - Named parameters (full names):
///   isosceles_trapezium(base1=10, base2=5, height=6, center=false);
module isosceles_trapezium(base1=0, base2=0, height=0, b1=0, b2=0, h=0, center=false) {
  b1 = base1 != 0 ? base1 : b1;
  b2 = base2 != 0 ? base2 : b2;
  h = height != 0 ? height : h;

  // Assertions to ensure valid input
  assert(b1 > 0, "base1 (or b1) must be greater than 0");
  assert(b2 > 0, "base2 (or b2) must be greater than 0");
  assert(h > 0, "height (or h) must be greater than 0");
  
  // Calculate offset for centering
  x_offset = center ? -b1 / 2 : 0;
  y_offset = center ? -h / 2 : 0;
  
  polygon(points = [
                    [x_offset, y_offset],
                    [x_offset + b1, y_offset],
                    [x_offset + (b1 + b2) / 2, y_offset + h],
                    [x_offset + (b1 - b2) / 2, y_offset + h]
                    ]);
}


/* 3D */

// Cylinder sector (3D) given an angle from 0 ecluded to 360 included: angle ∈ ] 0; 360 ]
module cylinder_sector(radius, height, start_angle, end_angle) {
  linear_extrude(height = height) {
    circle_sector(radius, start_angle, end_angle);
  }
}


/* Tarnsformations */

// Mirrors the child object along a plane defined by the Cartesian axis
// (XY, XZ, or YZ) while retaining the original object
module symmetry_plane(plane) {
  children();
  if (plane == "XY" || plane == "xy" || plane == "YX" || plane == "yx") {
    mirror([0, 0, 1]) children();
  } else if (plane == "XZ" || plane == "xz" || plane == "ZX" || plane == "zx") {
    mirror([0, 1, 0]) children();
  } else if (plane == "YZ" || plane == "yz" || plane == "ZY" || plane == "zy") {
    mirror([1, 0, 0]) children();
  } else {
    assert(false, "Invalid plane. Use 'XY', 'XZ', or 'YZ'.");
  }
}

/* Functions */

// Function to convert degrees to radians
function deg_to_rad(deg) = deg * PI / 180;

// Function to convert radians to degrees
function rad_to_deg(rad) = rad * 180 / PI;