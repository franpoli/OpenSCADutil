/*
 * cabletie.scad generates cable ties meant to be 3D printed in TPU
 */

// Variables default values
cabletie_width = 6;
cabletie_wrapping_diameter = 15;
cabletie_minimum_thickness = 1.2; // would be override if to large

// FDM 3D printer parameters
nozzle_width = 0.4;
printer_tolerance = 0.2;

// funcions
function cabletie_wrapping_circumference(d=cabletie_wrapping_diameter) = 3.14*d;
function cabletie_steps_lenth(w=cabletie_width, nw=nozzle_width) = (w-2*nw)*cos(30);
function cabletie_links_count(d=cabletie_wrapping_diameter, w=cabletie_width, nw=nozzle_width) = floor(cabletie_wrapping_circumference(d)/cabletie_steps_lenth(w, nw));
function retainer_hole_length(w=cabletie_width, nw=nozzle_width) = cabletie_steps_lenth(w, nw)/3;
function release_hole_length(w=cabletie_width, nw=nozzle_width) = cabletie_steps_lenth(w, nw);
function cabletie_maximum_thickness(w=cabletie_wrapping_diameter, nw=nozzle_width) = (cabletie_steps_lenth(w, nw)/3+nw)/tan(30)-(nw/sin(30)-nw);
function cabletie_thickness(mini_thickness, maxi_thickness) = mini_thickness > maxi_thickness ? maxi_thickness : mini_thickness;

// Resolution
$fa=2; // default minimum facet angle
$fs=0.2; // default minimum facet size

module cabletie(w=cabletie_width,
                d=cabletie_wrapping_diameter,
                t=cabletie_minimum_thickness,
                nw=nozzle_width,
                pt=printer_tolerance) {
     translate([0, 0, cabletie_thickness(t, cabletie_maximum_thickness(w, nw))/2])
     linear_extrude(height = cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                    center = true, convexity = 10, twist = 0) {
          difference() {
               //offset(r = 0) {
               offset(r = nozzle_width) { // smooth hard edges
                    union() {
                         // links
                         for (i = [0 : cabletie_steps_lenth(w, nw) : cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)-1)]) {
                    	         translate([i, 0, 0]) {
                                 
                                   polygon(points=[// shape of a regular link
                                                   [0,0],
                                                   [0,cabletie_steps_lenth(w, nw)/2],
                                                   [cabletie_steps_lenth(w, nw),0],
                                                   [0,-cabletie_steps_lenth(w, nw)/2]
                                                  ]);
                             }
                    	   }
                         // last link custom shape
                         translate([cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)+0.5), 0, 0]) {
                              circle(d = cabletie_steps_lenth(w, nw));
                         }
                         translate([cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)), -cabletie_steps_lenth(w, nw)/2, 0]) {
                              square([cabletie_steps_lenth(w, nw)/2, cabletie_steps_lenth(w, nw)]);
                         }
                         // connect all links
                         translate([0, -(cabletie_steps_lenth(w, nw)/3)/2, 0]) {
                              square([cabletie_steps_lenth(w, nw)*(cabletie_links_count(d, w, nw)), cabletie_steps_lenth(w, nw)/3]);
                         }
                         // locker
                         translate([-8*cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                                    -(release_hole_length(w, nw)+4*cabletie_thickness(t, cabletie_maximum_thickness(w, nw)))/2,
                                    0])
                         square([8*cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                                 release_hole_length(w, nw)+4*cabletie_thickness(t, cabletie_maximum_thickness(w, nw))]);
                    }
               }
               offset(r = nozzle_width) { // smooth hard edges
                    union() {
                         // release hole
                         translate([-3*cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                                    -release_hole_length(w, nw)/2-printer_tolerance,
                                    0])
                         square([cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                                 release_hole_length(w, nw)+2*printer_tolerance]);
                         // retainer hole
                         translate([-5*cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                                    -retainer_hole_length(w, nw)/2-printer_tolerance,
                                    0])
                         square([2*cabletie_thickness(t, cabletie_maximum_thickness(w, nw)),
                                      retainer_hole_length(w, nw)+2*printer_tolerance]);
                    }
               }
          }
     }
}

// Demo
//cabletie(6, 15, 1.0);
//translate([0, -12, 0]) cabletie(6, 20, 1.0);
//translate([0, -24, 0]) cabletie(6, 25, 1.0);
//
//translate([0, -40, 0]) cabletie(8, 20, 1.2);
//translate([0, -55, 0]) cabletie(8, 25, 1.2);
//translate([0, -70, 0]) cabletie(8, 30, 1.2);
//
//translate([0, -90, 0]) cabletie(10, 35, 1.4);
//translate([0, -108, 0]) cabletie(10, 45, 1.4);
//translate([0, -126, 0]) cabletie(10, 55, 1.4);

// Customizer
cabletie();
