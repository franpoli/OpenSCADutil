/*
OpenSCAD Reusable Modules and Function Library

This library contains a collection of reusable modules and functions that can be used in
various OpenSCAD projects. The modules are designed to perform common tasks, such as
creating geometric shapes, transformations, and other useful operations. Each module is
self-contained and can be easily integrated into other OpenSCAD scripts.
*/

/* Default values */

// Line thickness is the default thickness for a line in cartesian system representation
origin = !is_undef(origin) ? origin : [0, 0, 0];
line_thickness = !is_undef(line_thickness) ? line_thickness : 0.5;
multiplication_factor = !is_undef(multiplication_factor) ? multiplication_factor : 1.67;

/* 2D */

// Circle sector (2D) given an angle from 0 ecluded to 360 included: angle ∈ ] 0; 360 ]
module circle_sector(radius, start_angle, end_angle) {
    module sector_less_or_equal_to_90_degrees(radius, start_angle, end_angle) {
        triangle_sides_length = sqrt(2*pow(radius,2));
        intersection() {
            circle(radius);
            rotate(start_angle) {
                polygon(points = [[0, 0],
                                  [triangle_sides_length, 0],
                                  [triangle_sides_length * cos(end_angle - start_angle),
                                   triangle_sides_length * sin(end_angle - start_angle)]]);
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
module isosceles_trapezium(b = 2, t = 1, h = 1, base = 0, top = 0, height = 0, center = false) {
    // Determine the effective dimensions with consistent defaults
    effective_b = base > 0 ? base : b;  // Default to 2
    effective_t = top > 0 ? top : t;    // Default to 1
    effective_h = height > 0 ? height : h; // Default to 1

    // Assertions to ensure valid input
    if (effective_b <= 0 || effective_t <= 0 || effective_h <= 0) {
        assert(false, "base, top, and height (or b/t/h) must all be greater than 0");
    }

    // Calculate offset for centering
    x_offset = center ? -effective_b / 2 : 0;
    y_offset = center ? -effective_h / 2 : 0;

    // Create the trapezium
    polygon(points = [
        [x_offset, y_offset],
        [x_offset + effective_b, y_offset],
        [x_offset + (effective_b + effective_t) / 2, y_offset + effective_h],
        [x_offset + (effective_b - effective_t) / 2, y_offset + effective_h]
    ]);
}

// Create a rectangle trapezium with optional centering
module rectangle_trapezium(b = 2, t = 1, h = 1, base = 0, top = 0, height = 0, center = false) {
    // Resolve dimensions with meaningful defaults
    effective_b = base > 0 ? base : b;  // Default to 2
    effective_t = top > 0 ? top : t;    // Default to 1
    effective_h = height > 0 ? height : h; // Default to 1

    // Assertions to ensure valid input
    if (effective_b <= 0 || effective_t <= 0 || effective_h <= 0) {
        assert(false, "base, top, and height (or b/t/h) must all be greater than 0");
    }

    // Calculate offset for centering
    x_offset = center ? -effective_b / 2 : 0;
    y_offset = center ? -effective_h / 2 : 0;

    // Create the trapezium
    polygon(points = [
        [x_offset, y_offset],
        [x_offset + effective_b, y_offset],
        [x_offset + effective_t, y_offset + effective_h],
        [x_offset, y_offset + effective_h]
    ]);
}

// Create an ellipse
module ellipse(l = 2, w = 1, length = 0, width = 0) {
    // Determine the effective width and length with consistent defaults
    effective_w = width > 0 ? width : w;  // Default to 1
    effective_l = length > 0 ? length : l; // Default to 2

    // Assertions to ensure valid input
    if (effective_l <= 0 || effective_w <= 0) {
        assert(false, "length or width (or l/w) must be greater than 0");
    }

    // Create the ellipse
    scale([1, effective_w / effective_l, 1]) circle(d = effective_l);
}

// Applies fillets on reflex corners to a 2D shape without altering its overall size.
module fillet_reflex_angles(radius) {
    assert(radius > 0, "Radius must be greater than zero.");
    
    // Expand back 2d object
    offset(r=radius)
        // Shrink 2d object
        offset(delta=-radius)
        children();        
}

// Transforms a 2D shape into a hollow object by adding a wall of the specified width.
module thickness(width = -1) {
    // Inward
    if (sign(width) == -1) {
        difference() {
            children();
            offset(delta = width) children();
        }
    }
    // Outward
    else if (sign(width) == 1) {
        difference() {
            offset(delta = width) children();
            children();
        }
    } else {
        // Unchanged
        children();
        echo("Warning! Using thickness module with zero value.");
    }
}

// Module to generate a sinusoidal circle
module sinusoidal_circle(radius = 10,
                         amplitude = 0.5,
                         frequency = 36,
                         segments = 200) {
    points = [for (segment_index = [0 : segments - 1])
            let (angle = segment_index * 360 / segments) [
                compute_radius_at_angle(radius,
                                        amplitude,
                                        frequency,
                                        angle) * cos(angle),
                compute_radius_at_angle(radius,
                                        amplitude,
                                        frequency,
                                        angle) * sin(angle)]];
    polygon(points);  // Create the polygon from the generated points (2D)
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

// Bulge extrusion: creates a 3D shape with middle bulge
module bulge_extrude(height = 2, bulge = 1, steps = 5, layer = 0.01) {
  // Generate bulge profile points
  points = [for (z = [0:height/steps:height])
      [z, bulge * sin(180 * (z/height))]];
    
  // Create smooth hulled transitions
  for (i = [0:len(points)-2]) {
    hull() {
      for (k = [i, i+1])
	translate([0,0,points[k][0]])
	  linear_extrude(layer)
	  offset(points[k][1])
	  children(0);
    }
  }
}

/* Functions */

// Function to convert degrees to radians
function deg_to_rad(deg) = deg * PI / 180;

// Function to convert radians to degrees
function rad_to_deg(rad) = rad * 180 / PI;

// Function to compute the radius at a given angle using sinusoidal variation
function compute_radius_at_angle(radius, amplitude, frequency, angle) =
    radius + amplitude * sin(frequency * angle);

// Function that ensures a list has exactly three elements, padding with zeros if necessary
function pad_to_three(point) = 
    len(point) > 3 ? undef :
    len(point) < 3 ? concat(point, [for (i = [0:2-len(point)]) 0]) :
    point;

// Function to calculate dot (scalar) product
function dot(v1, v2) =
    let (
         u = pad_to_three(v1),
         v = pad_to_three(v2)
    )
    u[0] * v[0] + u[1] * v[1] + u[2] * v[2];

// Function to add vectors
function vector_addition(v1, v2) =
    let (
         u = pad_to_three(v1),
         v = pad_to_three(v2)
    )
    [for (i = [0:2]) u[i] + v[i]];

// Function to displace vectors
function vector_displacement(v1, v2) =
    let (
         u = pad_to_three(v1),
         v = pad_to_three(v2)
    )
    [for (i = [0:2]) v[i] - u[i]];

// Function to calculate the unit vector
function unit_vector(v) =
    let (n = norm(v))
    n == 0 ? [0, 0, 0] : [for (i = v) i / n];

// Calculate the slope between two points
function slope(p1, p2) = (p2[1] - p1[1]) / (p2[0] - p1[0]);

// Calculate the slope of a perpendicular line
function perpendicular_slope(slope) = -1 / slope;

// Function to compute the perpendicular vector in 2D (Z component is 0)
function perpendicular_vector(v) =
    [-v[1], v[0], 0];

// Function to find the intersection point of two lines
function lines_intersection(line1, line2) =
    let (
         m1 = slope(line1[0], line1[1]),
         b1 = line1[0][1] - m1 * line1[0][0],
         m2 = slope(line2[0], line2[1]),
         b2 = line2[0][1] - m2 * line2[0][0],
         x = (b2 - b1) / (m1 - m2),
         y = m1 * x + b1
    )
    [x, y];

// Function to find the intersection of a line through a point with a perpendicular line through another point
function perpendicular_intersection(point_line1, slope_line1, point_line2) = 
    let (
         m2 = perpendicular_slope(slope_line1),
         b1 = point_line1[1] - slope_line1 * point_line1[0],
         b2 = point_line2[1] - m2 * point_line2[0],
         x = (b2 - b1) / (slope_line1 - m2),
         y = slope_line1 * x + b1
    )
    [x, y];

// Function to create a new point by adding a distance vector to an existing point
function vector_point(point1, distance_vector) = 
    [point1[0] + distance_vector[0], point1[1] + distance_vector[1]];

function directional_vector(v) =
    let (length = norm(v))
    [for (i = v) i / length];

// Generate points for a parallel line at a specified distance
function parallel_vector(point1, point2, distance) =
    let (
         dir = vector_displacement(point1, point2),
         dir_normalized = unit_vector(dir),
         perp = perpendicular_vector(dir_normalized),
         perp_scaled = [perp[0] * distance, perp[1] * distance],
         p1 = vector_point(point1, perp_scaled),
         p2 = vector_point(point2, perp_scaled)
    )
    [p1, p2];

// XOR operation for boolean values
function xor(bool_a, bool_b) = 
    assert_valid_boolean_input(bool_a) && assert_valid_boolean_input(bool_b) ? bool_a != bool_b : false;

// Function to reduce a list of boolean values using XOR operation
function reduce_xor(values) =
    len(values) == 1
    ? values[0]  // Base case: single value
    : xor(values[0], reduce_xor(slice(values, 1, len(values))));  // Recursive XOR

// Helper function to slice an array manually
function slice(arr, start, end) =
    [for (i = [start : end - 1]) arr[i]];

// Assert function to validate boolean input (true '0' or false '1')
function assert_valid_boolean_input(value) =
    (value == true || value == false || value == 1 || value == 0) 
    ? true  // Return true if valid input
    : assert(false, str("Invalid value: ", value));

// Main function to convert integer to binary
function integer_to_binary(value) =
    value == 0 ? "0" : reverse_binary(value);

// Helper function to convert integer to binary
function reverse_binary(value, result = "") =
    value == 0 && result == "" ? "0" : ( // Base case: If value is 0 and result is empty, return "0"
        value == 0 ? result :  // If value reaches 0, return the accumulated result
        reverse_binary(floor(value / 2), str(value % 2, result))  // Correctly concatenate the binary string
    );

// Convert binary string to decimal
function binary_to_integer(binary) =
    let(
        digits = str(binary),  // Convert the binary input to a string
        _ = [for (c = digits) assert(c == "0" || c == "1", str("Invalid binary digit: ", c))],  // Validate binary digits
        decimal_array = [for (i = [0 : len(digits) - 1]) 
            (digits[i] == "1" ? 1 : 0) * pow(2, len(digits) - 1 - i)  // Explicitly convert boolean to numeric
        ]
    )
    accumulate_sum(decimal_array, 0, 0);  // Use existing accumulate_sum to sum contributions

// Main function to convert a string representing an integer to its numeric value
function to_number(str) =
    let(
        // Convert the string into an array of characters
        digits = [for (i = [0 : len(str)-1]) str[i]],

        // Check if the number is negative
        is_negative = (digits[0] == "-"),

        // Exclude the minus sign if negative
        abs_digits = is_negative ? [for (i = [1 : len(str)-1]) digits[i]] : digits,

        // Assert that all characters in the string are valid digits
        _ = [for (c = abs_digits) assert(ord(c) >= ord("0") && ord(c) <= ord("9"), str("String contains non-digit characters: ", str))],

        // Create the array of numeric values with place values
        temp_array = [for (i = [0 : len(abs_digits)-1]) (ord(abs_digits[i]) - ord("0")) * pow(10, (len(abs_digits)-i-1))],

        // Calculate the sum using recursion
        number = accumulate_sum(temp_array, 0, 0)
    )
    // Return the number, taking the sign into account
    is_negative ? -number : number;

// Helper function to accumulate the sum
function accumulate_sum(arr, index, acc) =
    index < len(arr) ? accumulate_sum(arr, index + 1, acc + arr[index]) : acc;

/* Cartesian Coordinate System */

// Draw a line segment given two points, with an optional parameter to extend the line beyond these points.
module draw_line(point1,
                 point2,
                 thickness = line_thickness,
                 extend = false,
                 factor = multiplication_factor) {
    // Ensure points have 3 coordinates for consistent handling
    point1 = pad_to_three(point1);
    point2 = pad_to_three(point2);

    // Calculate vector from two points
    v = vector_displacement(point1, point2);

    // Calculate extension points if needed
    if (extend) {
        ext_point1 = [point1[0] - factor * v[0],
                      point1[1] - factor * v[1],
                      point1[2] - factor * v[2]];
        ext_point2 = [point2[0] + factor * v[0],
                      point2[1] + factor * v[1],
                      point2[2] + factor * v[2]];

        hull() {
            draw_sphere_at(ext_point1, thickness); 
            draw_sphere_at(point1, thickness);
            draw_sphere_at(point2, thickness);
            draw_sphere_at(ext_point2, thickness);
        }
    } else { // If extend is false, draw the line segment
        hull() {
            draw_sphere_at(point1, thickness);
            draw_sphere_at(point2, thickness);
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

// Draw a point with optional line_thickness and cross highlight option.
module draw_point(point, cross = false, factor = multiplication_factor) {
    echo("Point", point);
    point_thickness = factor * line_thickness;
    // Ensure point has 3 coordinates for consistent handling
    point = pad_to_three(point);
    // Function to draw a cross at the origin
    module draw_cross(line_thickness) {
        for (i = [0:2]) {
            rotate([i*90, (i==2?1:0)*90, 0]) {
                translate([0, 0, -point_thickness / 2]) {
                    cylinder(h = point_thickness, d = line_thickness / 2);
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

// Draw a vector with arrow
module draw_vector(point1, point2, thickness = line_thickness) {
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
            draw_line(points[0], points[1], thickness);
            translate([points[1][0], points[1][1], points[1][2]]) {
                // Rotate around the calculated axis and angle
                rotate(a = angle, v = rotation_axis) {
                    draw_arrow(thickness);
                }
            }
        }
    }

    // Arrow vector representation
    module draw_arrow(thickness) {
        hull() {
            sphere(d = thickness);
            translate([0, 0, -4*thickness]) {
                cylinder(h = 1*thickness, d1 = thickness, d2 = 3*thickness);
            }
        }
    }
}

// Draw a parallelepiped with two vectors
module draw_parallelepiped(point1, point2, thickness = line_thickness/4) {
    let(u = pad_to_three(point1),
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
                              thickness = line_thickness,
                              bounding_box = false) {
    color("Red", 1.0) draw_vector([point1[0], point1[1], point1[2]],
                                  [point2[0], point1[1], point1[2]],
                                  thickness);
    color("Green", 1.0) draw_vector([point1[0], point1[1], point1[2]],
                                    [point1[0], point2[1], point1[2]],
                                    thickness);
    color("Blue", 1.0) draw_vector([point1[0], point1[1], point1[2]],
                                   [point1[0], point1[1], point2[2]],
                                   thickness);

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
