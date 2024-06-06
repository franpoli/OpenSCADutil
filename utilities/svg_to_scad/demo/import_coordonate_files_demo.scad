// Load the generated SCAD files
use <straight_lines.scad>
use <bezier_curves.scad>

// Use the polygon modules defined in the included files
translate([-200, -40, 0]) {
    linear_extrude(10)
    straight_lines();
}

translate([-100, -100, 0]) {
    linear_extrude(15)
    bezier_curves();
}