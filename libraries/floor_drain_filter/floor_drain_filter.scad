// floor_drain_filter.scad - A floor drain filter model generator for fused filament printers

/* [Filter parameters] */
filter_tab = "no"; // [no, yes]
drain_pattern = "square"; // [square, honeycomb, plain]
filter_diameter = 100; // Filter diameter
grain_diameter = 4; // Grain diameter
filter_height = 2; // Filter height
filter_border = 4; // Filter border
filter_grip_tab_angle = 30; // Filter grip tab angle

/* [Printer parameters] */
nozzle_width = 0.4; // Nozzle width

/* [Render parameters] */
render_convexity_value = 4;

// Precomputed Constants
$fa = $preview ? 5 : 2; // Minimum facet angle
$fs = $preview ? 3 : 2; // Minimum facet size

COS_30 = cos(30);
SQRT_2 = sqrt(2);
LAYER_HEIGHT = nozzle_width / 2;
ROUND_TO_STEP = floor(filter_border / nozzle_width) * nozzle_width;
ADJUSTED_HEIGHT = floor(filter_height / LAYER_HEIGHT) * LAYER_HEIGHT;
MINIMAL_HEIGHT = ADJUSTED_HEIGHT <= 2 ?
  ceil(ADJUSTED_HEIGHT / 2 / LAYER_HEIGHT) * LAYER_HEIGHT :
  ADJUSTED_HEIGHT - 1;
CHAMFER = filter_height <= 2 ?
  ceil(filter_height / 2 / LAYER_HEIGHT) * LAYER_HEIGHT :
  1;
HALF_DIAGONAL = grain_diameter / 2;
INNER_RADIUS = filter_diameter / 2 - ROUND_TO_STEP - CHAMFER;

// Helper Modules
module constants() {
  echo("Recommended printer settings:");
  echo(str("--> Nozzle width: ", nozzle_width, "mm"));
  echo(str("--> Layer height: ", LAYER_HEIGHT, "mm"));
  echo(str("--> Perimeters for plain infill: ",
           ceil(((ROUND_TO_STEP + CHAMFER) / nozzle_width) / 2)));
  if (ROUND_TO_STEP != filter_border || ADJUSTED_HEIGHT != filter_height) {
    echo("3D printing optimizations:");
    if (ROUND_TO_STEP != filter_border) {
      echo(str("Border value was set to ", ROUND_TO_STEP, " instead of ", filter_border));
    }
    if (ADJUSTED_HEIGHT != filter_height) {
      echo(str("Height value was set to ", ADJUSTED_HEIGHT, " instead of ", filter_height));
    }
  }
}

// Generates the 2D profile of the filter
module filter_profile() {
  polygon(points = [[0, 0],
                    [0, filter_diameter / 2 - CHAMFER],
                    [CHAMFER, filter_diameter / 2],
                    [ADJUSTED_HEIGHT, filter_diameter / 2],
                    [ADJUSTED_HEIGHT, filter_diameter / 2 - ROUND_TO_STEP],
                    [MINIMAL_HEIGHT, filter_diameter / 2 - CHAMFER - ROUND_TO_STEP],
                    [MINIMAL_HEIGHT, 0]]);
}

// Generates the grip tab for the filter
module filter_grip_tab() {
    polygon(points = [[ADJUSTED_HEIGHT, filter_diameter / 2 - ROUND_TO_STEP],
                      [ADJUSTED_HEIGHT, filter_diameter / 2],
                      [ADJUSTED_HEIGHT + ROUND_TO_STEP, filter_diameter / 2 - 5/4 * ROUND_TO_STEP],
                      [ADJUSTED_HEIGHT + ROUND_TO_STEP - 1, filter_diameter / 2 - 6/5 * ROUND_TO_STEP - CHAMFER],
                      [ADJUSTED_HEIGHT, filter_diameter / 2 - ROUND_TO_STEP]]);
}

// Generates a honeycomb pattern
module honeycomb_pattern() {
  X_STEP = (grain_diameter * COS_30 + 2 * nozzle_width * COS_30) * COS_30;
  Y_STEP = (grain_diameter / 2) * COS_30 + nozzle_width;
  offset = (X_STEP - ceil(filter_diameter / (2 * X_STEP)) * 2 * X_STEP) / 2;
  max_dist = INNER_RADIUS + HALF_DIAGONAL * 2;             
  x_range = ceil((INNER_RADIUS + HALF_DIAGONAL) / X_STEP);
  y_range = ceil((INNER_RADIUS + HALF_DIAGONAL) / Y_STEP);

  render(convexity = render_convexity_value) {
    for (x = [-x_range:1:x_range], y = [-y_range:1:y_range]) {
      for (step = [0:1:1]) {
        pos_x = offset + (2 * x + step) * X_STEP;
        pos_y = offset + (2 * y + step) * Y_STEP;
        if (sqrt(pos_x * pos_x + pos_y * pos_y) + HALF_DIAGONAL < max_dist) {
          translate([pos_x, pos_y, MINIMAL_HEIGHT / 2])
            cylinder($fn = 6, h = MINIMAL_HEIGHT, d = grain_diameter, center = true);
        }
      }
    }
  }
}

// Generates a square pattern
module square_pattern() {
  step = grain_diameter + 2 * nozzle_width;
  max_dist = INNER_RADIUS + (grain_diameter / 2) * SQRT_2 * 2;
  range = ceil((INNER_RADIUS + (grain_diameter / 2) * SQRT_2) / step);

  render(convexity = render_convexity_value) {
    for (ix = [-range:1:range], iy = [-range:1:range]) {
      pos = [ix * step, iy * step];
      center = pos + [grain_diameter / 2 + nozzle_width, grain_diameter / 2 + nozzle_width];
      if (norm(center) + (grain_diameter / 2) * SQRT_2 < max_dist) {
        translate([pos[0] + nozzle_width, pos[1] + nozzle_width, 0])
          cube(size = [grain_diameter, grain_diameter, MINIMAL_HEIGHT], center = false);
      }
    }
  }
}

// Generates a plain filter (for custom infill)
module plain_filter() {
  translate([0, 0, MINIMAL_HEIGHT / 2])
    cylinder(h = MINIMAL_HEIGHT, d = filter_diameter - 2 * (ROUND_TO_STEP + CHAMFER), center = true);
}

// Main module to generate the filter
module floor_drain_filter() {
  constants();
  difference() {
    union() {
      rotate_extrude(angle = 360)
        rotate([0, 0, 90])
        filter_profile();
      if (filter_tab == "yes") {
        rotate([0, 0, -filter_grip_tab_angle / 2])
          rotate_extrude(angle = filter_grip_tab_angle)
          rotate([0, 0, 90])
          filter_grip_tab();
      }
    }
    if (drain_pattern != "plain") {
      translate([0, 0, -(MINIMAL_HEIGHT * 0.1)/2])
        scale([1, 1, 1.1])
        intersection() {
        if (drain_pattern == "honeycomb") honeycomb_pattern();
        else square_pattern();
        plain_filter();
      }
    }
  }
  if (drain_pattern == "plain") {
    translate([0, 0, ADJUSTED_HEIGHT * (-2)])
      plain_filter();
  }
}

// Generate the Filter
floor_drain_filter();
