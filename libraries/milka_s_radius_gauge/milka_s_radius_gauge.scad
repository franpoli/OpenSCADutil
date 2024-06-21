/*
Customisable radius gauge. An OpenSCAD variant of Milka's radius gauge 1-20 (v1)
The original designed available at https://www.printables.com/model/137696-radius-gauge-1-20-mm/
is licensed under the Creative Commons - CC0 "No Rights Reserved" - Public Domain Dedication.

Milka's radius gauge was inspired by the "Radius Template" from _sibmaker_ released under CC BY-NC 4.0 license.
His model is available at https://www.thingiverse.com/thing:5205494

This code is released under GNU General Public License v3.0
Permissions of this strong copyleft license are conditioned on making available complete source
code of licensed works and modifications, which include larger works using a licensed work, under
the same license. Copyright and license notices must be preserved. Contributors provide an express
grant of patent rights.
*/

// OpenSCAD customizer variables
radius_step = 0.5; // [1/2:0.1:10]
minimum_radius = 1; // [1:0.5:13]
maximum_radius = 25; // [14:0.5:25]
printer_layer_height = 0.20; // [0.10, 0.15, 0.20, 0.25]
printer_tolerance = 0.20; // [0,05, 0.10, 0.15, 0.20, 0.25, 0.30]
screw_head_type = "Socket"; // ["Flat", "Socket"]
screw_metric_size = "M3"; // ["M3", "M4", "M5"]
label_font="Fira Sans:style=Bold";
parts = "All"; // ["All", "Inward_radius_gauges", "Outward_radius_gauges", "Covers", "Top_cover", "Bottom_cover"]
custom_cover_label = "";
support_material = false; // [true:false]

/* [Hidden] */
// Milka's gauge original dimensions
cover_screw_circle_radius = 7;
cover_ellipse_body_long_radius = 40;
cover_cutting_circle_radius = 17.5;
cover_cutting_circle_x_position = 35.268;
cover_cutting_circle_y_position = 25;

// Constraint values
minimum_target_thickness = 0.8;

// Offset for negative shape to solve some rendering issues;
cutting_offset = 0.01;

// screw and bolts dimensions table where:
FHD = 0; // Flat head diameter
SHD = 1; // Socket head diameter
SHH = 2; // Socket head height
NH  = 3; // Nut height
NW  = 4; // Nut width
TD  = 5; // Thread diameter

// Dimensions table using generic maximum values 
//               FHD=0; SHD=1; SHH=2; NH=3; NW=4; TD=5;
dimensions = [ [  6.72,  5.68,  3.00, 2.40, 5.50, 3.0 ],   // M3=0
               [  8.96,  7.22,  4.00, 3.20, 7.00, 4.0 ],   // M4=1
               [ 11.20,  8.72,  5.00, 4.00, 8.00, 5.0 ] ]; // M5=2

// Default redering resolution
$fa = $preview ? 5 : 1; // default minimum facet angle
$fs = $preview ? 2.5 : 0.5; // default minimum facet size

// Main module
module milka_radius_gauge( rstep = radius_step,
                           minir = minimum_radius,
                           maxir = maximum_radius,
                           plh = printer_layer_height,
                           pt = printer_tolerance ) {

  // Functions
  function thickness(target_value, layer_thickness)
    = ceil(target_value/layer_thickness)*layer_thickness;

  function number_of_steps(minimum_value, maximum_value, step_value)
    = floor((maximum_value-minimum_value)/radius_step);

  function gauges_stack_height(number_of_steps, gauge_thickness)
    = (number_of_steps+1)*gauge_thickness;

  function metric_size(screw_metric_size)
    = (screw_metric_size == "M3") ? 0
    : (screw_metric_size == "M4") ? 1 : 2; // 2 -> M5

  function highest_radius()
    = minir+rstep*floor((maxir-minir)/rstep);

  function screw_head_height()
    = (screw_head_type == "Socket") ? thickness(dimensions[metric_size][SHH], plh)
    : thickness(((dimensions[metric_size][FHD]-dimensions[metric_size][TD])/2), plh);

  function screw_head_diameter()
    = (screw_head_type == "Socket") ? dimensions[metric_size][SHD]+2*pt
    : dimensions[metric_size][FHD]+2*pt;

  function nut_height()
    = thickness(dimensions[metric_size][NH], plh);

  function nut_diameter()
    = 2*(dimensions[metric_size][NW]/sqrt(3))+pt;

  function thread_diameter()
    = dimensions[metric_size][TD]+2*pt;

  function screw_length(screw_type, socket_screw_heigth, flat_screw_heigth)
    = (screw_type == "Socket") ? socket_screw_heigth : flat_screw_heigth;

  // Compute constraint values
  minimum_thickness = thickness(minimum_target_thickness, plh);
  gauge_engravure_thickness = thickness(minimum_target_thickness/2, plh);
  number_of_steps = number_of_steps(minir, maxir, rstep);
  number_of_gauges_per_type = number_of_steps+1;
  stack_height = gauges_stack_height(number_of_steps, minimum_thickness);
  metric_size = metric_size(screw_metric_size);
  highest_radius = highest_radius();
  screw_head_height = screw_head_height();
  screw_head_diameter = screw_head_diameter();
  nut_height = nut_height();
  nut_diameter = nut_diameter();
  thread_diameter = thread_diameter();
  screw_length = screw_length( screw_head_type,
                               minimum_thickness+stack_height+nut_height,
                               minimum_thickness+stack_height+nut_height+screw_head_height );

  // Extrudes a 2D shape
  module extrude(height = minimum_thickness) {
    linear_extrude(height, center = true, convexity = 4, twist = 0) {
      children();
    }
  }

  // Mirror an object keeping the original one in place
  module symmetry(x = 0, y = 0, z = 0) {
    for (i = [0:1]) {
      mirror([i*x, i*y, i*z]) {
        children();
      }
    }
  }
  
  // Generates ellipse cover 2D shape
  module ellipse_body() {
    scale([1, 1/2]) circle(r = cover_ellipse_body_long_radius);
  }

  // Genrates thread hole 2D template
  module thread_hole() {
    translate([cover_ellipse_body_long_radius, 0, 0]) {
      circle(d = dimensions[metric_size][TD]+2*pt);
    }
  }

  // Generates thumbs cutting 2D template
  module ellipse_body_cutting_circles() {
    for (i = [0:1]) {
      rotate([0, 0, 180*i]) {
        translate([cover_cutting_circle_x_position, cover_cutting_circle_y_position, 0]) {
          circle(r = cover_cutting_circle_radius);
        }
      }
    }
  }

  // Generates fastner 2D shape
  module gauge_fastener() {
    hull() {
      difference() {
        intersection() {
          ellipse_body();
          translate([cover_ellipse_body_long_radius, 0, 0]) {
            square([cover_screw_circle_radius, cover_ellipse_body_long_radius], center=true);
          }
        }
        hull() { //ellipse_body_cutting_intersection();
          symmetry(y = 1) {
            intersection() {
              ellipse_body();
              ellipse_body_cutting_circles();
            }
          }
        }
      }
      translate([cover_ellipse_body_long_radius, 0, 0]) {
        circle(r = cover_screw_circle_radius);
      }
    }
  }

  // Generates cover 2D shape
  module cover_2d_shape(offset_value = 0) {
    union() {
      symmetry(x = 1) gauge_fastener();
      difference() {
        ellipse_body();
        offset(offset_value) ellipse_body_cutting_circles();
      }
    }
  }

  // Defines label orientation
  module label(height, length, width, string, x_position = 0, z_position = 0, cover = false) {
    z_rotation = (cover == false) ? 90 : 0;
    translate([x_position, 0, z_position]) {
      extrude(height) {
        rotate([0, 0, z_rotation]) {
          resize([length, width], auto = true) {
            text(string, valign = "center", halign = "center", font = label_font);
          }
        }
      }
    }
  }
  
  // Extrudes a radius gauge 2D shape and engrave radius label 
  module engrave_radius_label(radius) {
    difference() {
      extrude(minimum_thickness) children();
      label(gauge_engravure_thickness, 0, 5, str(radius), 29, (minimum_thickness-gauge_engravure_thickness)/2);
    }
  }

  // Generates top cover label
  module cover_label() {
    cover_label = (custom_cover_label != "") ? custom_cover_label : str("Radius ", minir, ":", rstep, ":", highest_radius);
    translate([0, 0, minimum_thickness/(-2)]) rotate([0, 0, -90]) label(minimum_thickness+cutting_offset, 0, 6, cover_label, 0);
  }

  // Generates screw heads negatives shape
  module negative_screw_heads(support = support_material) {
    if (screw_head_type == "Socket") {
      symmetry(x = 1) union() {
        translate([cover_ellipse_body_long_radius, 0, (2*minimum_thickness+screw_head_height)/(-2)]) {
          cylinder(h=minimum_thickness, d=thread_diameter, center=false);
          if (!support) {
            translate([0, 0, minimum_thickness]) {
              cylinder(h=screw_head_height+minimum_thickness+cutting_offset, d=screw_head_diameter, center=false);
            }
          } else {
            translate([0, 0, minimum_thickness+plh]) {
              cylinder(h=screw_head_height+minimum_thickness-plh+cutting_offset, d=screw_head_diameter, center=false);
            }
          }
        }
      }
    } else {
      symmetry(x = 1) union() {
        translate([cover_ellipse_body_long_radius, 0, (2*minimum_thickness+screw_head_height)/(-2)]) {
          cylinder(h=minimum_thickness, d=thread_diameter, center=false);
          translate([0, 0, minimum_thickness]) {
            cylinder(h=screw_head_height+cutting_offset, d1=thread_diameter, d2=screw_head_diameter, center=false);
          }
          translate([0, 0, minimum_thickness+screw_head_height]) {
            cylinder(h=minimum_thickness+cutting_offset, d=screw_head_diameter, center=false);
          }
        }
      }
    }
  }

  // Generates nut negatives shape
  module negative_nut(support = support_material) {
    symmetry(x = 1) union() {
      translate([cover_ellipse_body_long_radius, 0, nut_height/(-2)-minimum_thickness]) {
        cylinder(h=minimum_thickness, d=thread_diameter, center=false);
        if (!support) {
          translate([0, 0, minimum_thickness]) {
            cylinder(h=nut_height+minimum_thickness+cutting_offset, d=nut_diameter, center=false, $fn=6);
          }
        } else {
          translate([0, 0, minimum_thickness+plh]) {
            cylinder(h=nut_height+minimum_thickness-plh+cutting_offset, d=nut_diameter, center=false, $fn=6);
          }
        }
      }
    }
  }

  // Generates a single inward or outward radius gauge 2D shape
  module gauge(radius, inward_radius = true) {
    difference() {
      union() {
        gauge_fastener();
        intersection() {
          difference() { 
            intersection() {
              ellipse_body();
              translate([cover_ellipse_body_long_radius/sqrt(2), 0, 0]) {
                rotate([0, 0, 45]) {
                  square([cover_ellipse_body_long_radius, cover_ellipse_body_long_radius], center = true);
                }
              }
            }
            if (inward_radius) circle(r = radius);
          }
          if (!inward_radius) {
            union() {
              translate([2*radius/sqrt(2), 0, 0]) {
                circle(r = radius);
              }
              translate([radius/sqrt(2), -cover_ellipse_body_long_radius/2, 0]) {
                square([cover_ellipse_body_long_radius, cover_ellipse_body_long_radius], center = false);
              }
            }
          }
        }
      }
      thread_hole();
    }
  }

  // Generates multiple radius gauges
  module gauges(inward_radius = true) {
    t = (inward_radius == true) ? 1 : 0;
    module stack(inward_radius) {
      for (i = [minir:rstep:highest_radius]) {
        rotate([180*t, 0, 180*t]) {
          translate([0, 0, minimum_thickness*(i/rstep-minir/rstep)+(minimum_thickness-stack_height)/2]) {
            extrude(minimum_thickness) gauge(i, inward_radius);
          }
        }
      }
    }
    module grid(nward_radius) {
      subdivisions = ceil(sqrt(number_of_gauges_per_type));
      for (x = [1:subdivisions]) {
        for (y = [1:subdivisions]) {
          if (y+(x-1)*subdivisions <= number_of_gauges_per_type) {
            for (i = [(x-1)*subdivisions*rstep:rstep:(x-1)*subdivisions*rstep]) {
              current_radius = minir+((y+(x-1)*subdivisions)-1)*rstep;
              current_mini_radius = minir+(x-1)*subdivisions*rstep;
              current_maxi_radius = minir+x*subdivisions*rstep;
              rotate([0, 0, 180*t]) {
                translate([x*1.2*cover_ellipse_body_long_radius, y*cover_ellipse_body_long_radius, minimum_thickness/2]) {
                  engrave_radius_label(current_radius) gauge(current_radius, inward_radius);
                }
              }
            }
          }
        }
      }
    }
    if ($preview) {
      stack(inward_radius);
    } else {
      grid(inward_radius);
    }
  }

  // Generates a cover
  module cover(bottom_cover = false) {
    cover_height = (bottom_cover) ? 2*minimum_thickness+nut_height : 2*minimum_thickness+screw_head_height;
    difference() {
      union() {
        translate([0, 0, minimum_thickness/(-2)]) extrude(cover_height-minimum_thickness) cover_2d_shape();
        translate([0, 0, cover_height/2-minimum_thickness]) {
          for (i = [plh:plh:minimum_thickness]) {
            translate([0, 0, i-plh/2]) extrude(plh) {
              offset(-i) cover_2d_shape();
            }
          }
        }
      }
      if (!bottom_cover) {
        negative_screw_heads();
        translate([0, 0, screw_head_height/2+minimum_thickness]) cover_label();
      } else {
        negative_nut();
      }
    }
  }

  // Generates top and bottom covers
  module covers() {
    if ($preview) {
      translate([0, 0, (stack_height+2*minimum_thickness+screw_head_height)/2]) {
        cover(bottom_cover = false);
      }
      translate([0, 0, (stack_height+2*minimum_thickness+nut_height)/(-2)]) {
        mirror([0, 1, 0]) rotate([180, 0, 0]) {
          cover(bottom_cover = true);
        }
      }
    } else if (parts == "All" || parts == "Covers") {
      rotate([0, 0, -45]) {
        translate([5/3*cover_ellipse_body_long_radius, 0, screw_head_height/2+minimum_thickness]) {
            cover(bottom_cover = false);
        }
        translate([(-5/3)*cover_ellipse_body_long_radius, 0, nut_height/2+minimum_thickness]) {
          mirror([0, 1, 0]) cover(bottom_cover = true);
        }
      }
    }
  }

  // Returns information about the generated models
  module gauge_information() {
    echo("*****************************************");
    echo("GAUGE DETAILS:");
    echo("Lowest radius", str(minir));
    echo("Highest radius", str(highest_radius));
    echo("Radius step", str(rstep));
    echo("-----------------------------------------");
    echo("PRINTER SETTINGS:");
    echo("Layer height", str(plh));
    echo("Printer tolerance", str(pt));
    echo("-----------------------------------------");
    echo("HARDWARE");
    echo("Metric size", str(screw_metric_size));
    echo("Screw head type", str(screw_head_type));
    echo("Screw estimated length", str(screw_length));
    echo("*****************************************");
  }

  // Generates parts
  module render_parts() {
    if (parts == "All" || parts == "Inward_radius_gauges") {
      color("Gold", 1.0) gauges(inward_radius = true);
    } else if ($preview) {
      color("Gold", 0.2) gauges(inward_radius = true);
    }
    
    if (parts == "All" || parts == "Outward_radius_gauges") {
      color("Gold", 1.0) gauges(inward_radius = false);
    } else if ($preview) {
      color("Gold", 0.2) gauges(inward_radius = false);
    }
    
    if (parts == "All" || parts == "Covers") {
      color("Olive", 1.0) covers();
    } else if ($preview) {
      color("Olive", 0.5) covers();
    }

    if (parts == "Top_cover" && !$preview) {
      color("Olive", 1.0) translate([0, 0, screw_head_height/2+minimum_thickness]) cover(bottom_cover = false);
    } else if ($preview) {
      color("Olive", 1.0) covers();
    }

    if (parts == "Bottom_cover" && !$preview) {
      color("Olive", 1.0) translate([0, 0, nut_height/2+minimum_thickness]) cover(bottom_cover = true);
    } else if ($preview) {
      color("Olive", 1.0) covers();
    }
  }

  // Main
  render_parts();
  gauge_information();
}

/* Customizer instance */
milka_radius_gauge();
