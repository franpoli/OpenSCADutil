/*
OpenSCAD Reusable Modules and Function Library

This library contains a collection of reusable modules and functions that can be used in
various OpenSCAD projects. The modules are designed to perform common tasks, such as
creating geometric shapes, transformations, and other useful operations. Each module is
self-contained and can be easily integrated into other OpenSCAD scripts.
*/

/* Default values */

// Line thickness is the default thickness for a line in cartesian system representation
line_thickness = !is_undef(line_thickness) ? line_thickness : 1;
multiplication_factor = !is_undef(multiplication_factor) ? multiplication_factor : 1;

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

// Funcion that make sure that a list has at list three elements, in order
// to make sure we work with three coordinates vector
function pad_to_three(point) = 
  len(point) > 3 ? undef :
  len(point) < 3 ? concat(point, [for (i = [0:2-len(point)]) 0]) :
  point;

// Function to calculate dot (saclar) product
function dot(point1, point2) =
  let(
      u = pad_to_three(point1),
      v = pad_to_three(point2)
  )
  u[0] * v[0] + u[1] * v[1] + u[2] * v[2];

// Function to add vectors
function vector_addition(point1, point2) =
  let(
      p1 = pad_to_three(point1),
      p2 = pad_to_three(point2)
  )
  [p2[0] + p1[0], p2[1] + p1[1], p2[2] + p1[2]];

// Function to displace vectors, ensuring both points have 3 coordinates
function vector_displacement(point1, point2) = 
  let(
      p1 = pad_to_three(point1),
      p2 = pad_to_three(point2)
  )
  [p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]];
  
// Function to calculate the unit vector
function unit_vector(v) =
  let (n = norm(v))
  n == 0 ? [0, 0, 0] : [v[0] / n, v[1] / n, v[2] / n];

// Calculate the slope between two points
function slope(point1, point2) =
  (point2[1] - point1[1]) / (point2[0] - point1[0]);

// Calculate the slope of the perpendicular line
function perpendicular_slope(slope) = -1 / slope;

// Function to compute the perpendicular vector from point1 (tail) to point2 (tip)
function perpendicular_vector(point1, point2) =
  let(
      p1 = pad_to_three(point1),
      p2 = pad_to_three(point2),
      // change the reference to the origin
      o_factor = [p1[0], -p1[1], p1[2]],
      v_tail = [-o_factor[0]*p1[0] + o_factor[1]*p1[1] + o_factor[2]*p1[2],
                o_factor[0]*p1[0] - o_factor[1]*p1[1] + o_factor[2]*p1[2],
                -o_factor[0]*p1[0] - o_factor[1]*p1[1] - o_factor[2]*p1[2]],
      v_tip = [-o_factor[0]*p2[0] + o_factor[1]*p2[1] + o_factor[2]*p2[2],
               o_factor[0]*p2[0] - o_factor[1]*p2[1] + o_factor[2]*p2[2],
               -o_factor[0]*p2[0] - o_factor[1]*p2[1] - o_factor[2]*p2[2]],
      v_perp_at_origin = [v_tip[2] - v_tail[2], v_tail[0] - v_tip[0], v_tip[1] - v_tail[1]]
  )
  [p1[0]*v_perp_at_origin[0],
   p1[1]*v_perp_at_origin[1],
   p1[2]*v_perp_at_origin[2]];

// Function to find the intersection point of two lines
function lines_intersection(line1, line2) =
  let(
      line1_point1 = line1[0],
      line1_point2 = line1[1],
      line2_point1 = line2[0],
      line2_point2 = line2[1],
      m1 = slope(line1_point1, line1_point2),
      b1 = line1_point1[1] - m1 * line1_point1[0],
      m2 = slope(line2_point1, line2_point2),
      b2 = line2_point1[1] - m2 * line2_point1[0],
      x = (b2 - b1) / (m1 - m2),
      y = m1 * x + b1
  )
  [x, y];

// Find the intersection point of a line through point1 with slope m1 and a perpendicular line through point2
function perpendicular_intersection(point_line1, slope_line1, point_line2) = 
    let(
        m2 = perpendicular_slope(slope_line1),
        b1 = point_line1[1] - slope_line1 * point_line1[0],
        b2 = point_line2[1] - m2 * point_line2[0],
        x = (b2 - b1) / (slope_line1 - m2),
        y = slope_line1 * x + b1
    )
    [x, y];

// Create a new point by adding a distance vector to an existing point
function vector_point(point1, distance_vector) = 
  [point1[0] + distance_vector[0], point1[1] + distance_vector[1]];

// Calculate the slope of a perpendicular line
function perpendicular_slope(slope) = -1 / slope;

// Normalize a vector
function normalize(vector) = vector / sqrt(vector[0] * vector[0] + vector[1] * vector[1]);

// Generate points for a parallel line at a specified distance
function parallel_vector(point1, point2, distance) =
  let(
      dir = [point2[0] - point1[0], point2[1] - point1[1]],
      dir_normalized = normalize(dir),
      perp = perpendicular_vector(dir_normalized),
      perp_scaled = [perp[0] * distance, perp[1] * distance],
      p1 = vector_point(point1, perp_scaled),
      p2 = vector_point(point2, perp_scaled)
  )
  [p1, p2];


/* Cartesian Coordinate System */

// Draw a line segment given two points, with an optional parameter to extend the line beyond these points.
module draw_line(point1, point2,
                 line_thickness = line_thickness,
                 extend = false, multiplication_factor = multiplication_factor) {
  // Ensure points have 3 coordinates for consistent handling
  point1 = pad_to_three(point1);
  point2 = pad_to_three(point2);

  // Calculate vector from two points
  v = vector_displacement(point1, point2);

  // Calculate extension points if needed
  if (extend) {
    ext_point1 = [point1[0] - multiplication_factor * v[0],
                  point1[1] - multiplication_factor * v[1],
                  point1[2] - multiplication_factor * v[2]];
    ext_point2 = [point2[0] + multiplication_factor * v[0],
                  point2[1] + multiplication_factor * v[1],
                  point2[2] + multiplication_factor * v[2]];

    hull() {
      draw_sphere_at(ext_point1, line_thickness); 
      draw_sphere_at(point1, line_thickness);
      draw_sphere_at(point2, line_thickness);
      draw_sphere_at(ext_point2, line_thickness);
    }
  } else { // If extend is false, draw the line segment
    hull() {
      draw_sphere_at(point1, line_thickness);
      draw_sphere_at(point2, line_thickness);
    }
  }
  // Function to draw a sphere at a given point with specified diameter
  module draw_sphere_at(point, diameter) {
    point = pad_to_three(point);
    translate(point) {
      sphere(d = diameter);
    }
  }
}

// Draw a vector with arrow
module draw_vector(point1, point2, line_thickness = line_thickness) {
  // Use three dimensional vectors
  points = [pad_to_three(point1), pad_to_three(point2)];
  
  // Calculate vector direction
  v = vector_displacement(points[0], points[1]);

  // Normalized direction vector
  direction = unit_vector(v);
  
  // Reference direction (z-axis)
  ref_dir = [0, 0, 1];
  
  // Calculate the axis of rotation using cross product
  rotation_axis = cross(ref_dir, direction);
  
  // Calculate the angle of rotation using dot product
  angle = acos(dot(ref_dir, direction));

  // Calculate vector length
  v_length = norm(v);

  if (v_length != 0) {
    color("Purple", 1.0) {
      draw_line(points[0], points[1], line_thickness);
      translate([points[1][0], points[1][1], points[1][2]]) {
        // Rotate around the calculated axis and angle
        rotate(a = angle, v = rotation_axis) {
          draw_arrow(line_thickness);
        }
      }
    }
  }

  // Arrow vector representation
  module draw_arrow(line_thickness = line_thickness) {
    hull() {
      sphere(d = line_thickness);
      translate([0, 0, -4*line_thickness]) {
        cylinder(h = 1*line_thickness, d1 = line_thickness, d2 = 3*line_thickness);
      }
    }
  }
}

// Draw a point with optional line_thickness and cross highlight option.
module draw_point(point, cross = false) {
  point_thickness = 3*line_thickness;
  // Ensure point has 3 coordinates for consistent handling
  point = pad_to_three(point);
  // Function to draw a cross at the origin
  module draw_cross(line_thickness) {
    for (i = [0:2]) {
      rotate([i*90, (i==2?1:0)*90, 0]) {
        translate([0, 0, -point_thickness/2]) {
          cylinder(h = point_thickness, d = line_thickness);
        }
      }
    }
  }

  translate(point) {
    if (cross) {
      draw_cross(line_thickness);
    } else {
      sphere(d = point_thickness);
    }
  }
}

// Draw a parallelepiped with two vectors
module draw_parallelepiped(point1, point2, thickness = line_thickness/4) {
  let(
      u = pad_to_three(point1),
      v = pad_to_three(point2),
      // Define points of the parallelepiped
      point_a = [0, 0, 0],
      point_b = u,
      point_c = vector_addition(u, v),
      point_d = v,
      points_list = [point_a, point_b, point_c, point_d,
                     vector_addition(point_a, [0, 0, thickness]),
                     vector_addition(point_b, [0, 0, thickness]),
                     vector_addition(point_c, [0, 0, thickness]),
                     vector_addition(point_d, [0, 0, thickness])]
  )

  // Create the parallelepiped as a 3D polyhedron
  color("Purple", 0.5) {
    polyhedron(points = points_list,
               faces = [[0, 1, 2, 3],
                        [4, 5, 6, 7],
                        [0, 1, 5, 4],
                        [1, 2, 6, 5],
                        [2, 3, 7, 6],
                        [3, 0, 4, 7]]);
  }
}

module draw_vector_components(point1, point2,
                              line_thickness = line_thickness,
                              bounding_box = false) {
  color("Red", 1.0) draw_vector([point1[0], point1[1], point1[2]],
                                        [point2[0], point1[1], point1[2]],
                                        line_thickness);
  color("Green", 1.0) draw_vector([point1[0], point1[1], point1[2]],
                                          [point1[0], point2[1], point1[2]],
                                          line_thickness);
  color("Blue", 1.0) draw_vector([point1[0], point1[1], point1[2]],
                                         [point1[0], point1[1], point2[2]],
                                         line_thickness);

  if ($preview || bounding_box) {
    color("LightGrey", 0.5) {
      polyhedron (points = [[point1[0], point1[1], point1[2]],
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
}
