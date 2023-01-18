/*
Demo script using thumbdrive_housing.scad
*/

use <thumbdrive_housing.scad>

thumbdrive_housing("TEXT", "None");

translate([0, 50, 0])
thumbdrive_housing("Demo", "S");

translate([0, -50, 0])
thumbdrive_housing("OpenSCAD", "M");

translate([0, -110, 0])
thumbdrive_housing("3D print", "L");
