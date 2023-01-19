/*
Demo script using thumbdrive_housing.scad
*/

use <thumbdrive_housing.scad>

thumbdrive_housing(l="TEXT", kb="Tiny", il=true);

translate([0, 50, 0])
thumbdrive_housing("Demo", "S", false);

translate([0, -50, 0])
thumbdrive_housing("OpenSCAD", "M", true);

translate([0, -110, 0])
thumbdrive_housing("3D print", "L", true);
