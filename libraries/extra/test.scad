use <extra.scad>

minor_angle = 60;
straight_angle = 180;
major_angle = 240;
radius = 80;
start_angle = 45;

// Create a minor sector
translate([-180, 0, 0]) {
  circle_sector(radius, start_angle, start_angle + minor_angle);
}

// Create a semicircula sector
circle_sector(radius, start_angle, start_angle + straight_angle);

// Create a major sector
translate([180, 0, 0]) {
  circle_sector(radius, start_angle, start_angle + major_angle);
}
