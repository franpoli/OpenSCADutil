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

// Create an isosceles trapezium with optional centering
module isosceles_trapezium(base=0, top=0, height=0, b=0, t=0, h=0, center=false) {
  b = base != 0 ? base : b;
  t = top != 0 ? top : t;
  h = height != 0 ? height : h;

  // Assertions to ensure valid input
  if (b <= 0 || t <= 0 || h <= 0) {
    assert(false, "base, top or height must be greater than 0");
  }

  // Calculate offset for centering
  x_offset = center ? -b / 2 : 0;
  y_offset = center ? -h / 2 : 0;
  
  polygon(points = [
                    [x_offset, y_offset],
                    [x_offset + b, y_offset],
                    [x_offset + (b + t) / 2, y_offset + h],
                    [x_offset + (b - t) / 2, y_offset + h]
                    ]);
}

// Create a rectangle trapezium with optional centering
module rectangle_trapezium(base=0, top=0, height=0, center=false) {
  b = base != 0 ? base : b;
  t = top != 0 ? top : t;
  h = height != 0 ? height : h;

  // Assertions to ensure valid input
  if (b <= 0 || t <= 0 || h <= 0) {
    assert(false, "base, top or height must be greater than 0");
  }

  // Calculate offset for centering
  x_offset = center ? -b / 2 : 0;
  y_offset = center ? -h / 2 : 0;

  polygon(points=[
                  [x_offset, y_offset],
                  [x_offset + b, y_offset],
                  [x_offset + t, y_offset + h],
                  [x_offset, y_offset + h]
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

// Function to calculate dot (saclar) product
function dot(v1, v2) = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];

// Function to calculate cross product
function cross(v1, v2) = [v1[1] * v2[2] - v1[2] * v2[1],
                          v1[2] * v2[0] - v1[0] * v2[2],
                          v1[0] * v2[1] - v1[1] * v2[0]];

// Function to add vectors
function vector_addition(point1, point2) =
  [point2[0] + point1[0], point2[1] + point1[1], point2[2] + point1[2]];

// Function to displace vectors
function vector_displacement(point1, point2) =
  [point2[0] - point1[0], point2[1] - point1[1], point2[2] - point1[2]];

// Function to calculate Euclidean norm
function norm(v) = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);

// Function to calculate the unit vector
function unit_vector(v) =
  let (n = norm(v))
  n == 0 ? [0, 0, 0] : [v[0] / n, v[1] / n, v[2] / n];

/* Cartesian Coordinate System */

// Draw a line segment given two points, with an optional parameter to extend the line beyond these points.
module line_illustration(point1, point2, thickness, extend = false, ext_factor = 1) {
  // Calculate vector from two points
  v = vector_displacement(point1, point2);

  // Calculate unit vector and magnitude of the line segment
  u = unit_vector(v);
  len_v = norm(v);

  // If extend is true, calculate extension points
  if (extend) {
    ext_point1 = [point1[0] - ext_factor * v[0], point1[1] - ext_factor * v[1], point1[2] - ext_factor * v[2]];
    ext_point2 = [point2[0] + ext_factor * v[0], point2[1] + ext_factor * v[1], point2[2] + ext_factor * v[2]];

    hull() {
      translate([ext_point1[0], ext_point1[1], ext_point1[2]]) sphere(d = thickness);
      translate([point1[0], point1[1], point1[2]]) sphere(d = thickness);
      translate([point2[0], point2[1], point2[2]]) sphere(d = thickness);
      translate([ext_point2[0], ext_point2[1], ext_point2[2]]) sphere(d = thickness);
    }
  } else { // If extend is false, draw the line segment
    hull() {
      translate([point1[0], point1[1], point1[2]]) sphere(d = thickness);
      translate([point2[0], point2[1], point2[2]]) sphere(d = thickness);
    }
  }
}

// Draw a vector with arrow
module vector_illustration(point1, point2, thickness) {  
  // Calculate vector direction
  v = vector_displacement(point1, point2);

  // Normalized direction vector
  direction = unit_vector(v);
  
  // Reference direction (z-axis)
  ref_dir = [0, 0, 1];
  
  // Calculate the axis of rotation using cross product
  rotation_axis = cross(ref_dir, direction);
  
  // Calculate the angle of rotation using dot product
  angle = acos(dot(ref_dir, direction));

  color("Purple", 1.0) {
    line_illustration(point1, point2, thickness);
    translate([point2[0], point2[1], point2[2]]) {
      // Rotate around the calculated axis and angle
      if (norm(v) > 0) {
        rotate(a = angle, v = rotation_axis) {
          arrow_illustration(thickness);
        }
      }
    }
  }

  // Arrow vector representation
  module arrow_illustration(thickness) {
    hull() {
      sphere(d = thickness);
      translate([0, 0, -4*thickness]) {
        cylinder(h = 1*thickness, d1 = thickness, d2 = 3*thickness);
      }
    }
  }
}

// Cross illustration that can be used to highlight points 
module point_illustration(point, thickness) {
  translate([point[0], point[1], point[2]]) {
    for (i = [0:2]) {
      rotate([i*90, (i==2?1:0)*90, 0]) {
        translate([0, 0, -2*thickness]) {
          cylinder(h = 4*thickness, d = thickness);
        }
      }
    }
  }
}

module vector_components_illustartion(point1, point2, thickness, bounding_box = false) {
  color("Red", 1.0) vector_illustration([point1[0], point1[1], point1[2]],
                                        [point2[0], point1[1], point1[2]],
                                        thickness);
  color("Green", 1.0) vector_illustration([point1[0], point1[1], point1[2]],
                                          [point1[0], point2[1], point1[2]],
                                          thickness);
  color("Blue", 1.0) vector_illustration([point1[0], point1[1], point1[2]],
                                         [point1[0], point1[1], point2[2]],
                                         thickness);

  if ($preview || bounding_box) {
    color("Grey", 0.5) polyhedron (points = [[point1[0], point1[1], point1[2]],
                                             [point2[0], point1[1], point1[2]],
                                             [point2[0], point2[1], point1[2]],
                                             [point1[0], point2[1], point1[2]],
                                             [point1[0], point1[1], point2[2]],
                                             [point2[0], point1[1], point2[2]],
                                             [point2[0], point2[1], point2[2]],
                                             [point1[0], point2[1], point2[2]]],

                                   faces = [[0,1,2,3],
                                            [4,5,1,0],
                                            [7,6,5,4],
                                            [5,6,2,1],
                                            [6,7,3,2],
                                            [7,4,0,3]]);
  }
}
