/*
Hakko FX-888D magnetic tips holder
*/

// Dependencies
use <extra.scad>
include <03by.scad>

/* [Models and parts] */
model = "01by"; // [01by, 03by]

/* [Printer settings] */
// layer height
layer_height = 0.20; // [0.05,0.010,0.15,0.20,0.25,0.30,0.35,0.40]
// printer tolerance
printer_tolerance = 0.2; // [0.05,0.010,0.15,0.20,0.25,0.30,0.35,0.40]

/* [Adjustement settings] */
shape_offset = 0; // [-1.0:0.1:1.0]
clips_height_position = 3.9; // [3.0:0.1:5.0]

/* [Hidden] */
number_of_magnets = 5;
magnet_diameter = 8;
filet = 1;
//chamfer = 1;

// Default redering resolution
$fa = $preview ? 5 : 1; // default minimum facet angle
$fs = $preview ? 1 : 0.5; // default minimum facet size

/* script modules */
// Generates a series of circles that are tangent to each other along a circular arc
module tangent_circles_on_a_circular_arc(number_of_circles,
                                         circle_diameter,
                                         arc_radius) {

  function sector_angle(circle_diameter, arc_radius) =
    asin(circle_diameter / arc_radius);

  // Calculate total rotation to center the arc
  rotation_angle =
    -sector_angle(circle_diameter, arc_radius) * (number_of_circles - 1) / 2 - 90;

  rotate([0, 0, rotation_angle]) {
    // Iterate through each circle
    for (i = [0:number_of_circles - 1]) {
      angle = i * sector_angle(circle_diameter, arc_radius);
            
      // Precompute positions
      x = cos(angle) * arc_radius;
      y = sin(angle) * arc_radius;
      
      translate([x, y])
        circle(d = circle_diameter);
    }
  }
}

// Merges a series of tangent circles and smooths the boundaries where they meet
module smooth_circles_union(number_of_circles,
                    circle_diameter,
                    arc_radius,
                    filet,
                    tolerance) {
  offset(r = -2*filet) {
    offset(r = 2*(filet+printer_tolerance)) {
      union() {
        tangent_circles_on_a_circular_arc(number_of_magnets,
                                          magnet_diameter,
                                          arc_radius);
      }
    }
  }
}

module 01by_shape(shape_offset = 0) {
  offset(r = shape_offset) {
    union() {
      symmetry_plane("YZ") translate([30/2, 0, 0]) circle(r = 8.4);
      difference() {
        translate([0, 38*cos(2*asin(15/38)/2), 0]) {
          circle_sector(46.4,
                        (270 - 2*asin(15/38)/2),
                        (270 - 2*asin(15/38)/2) + 2*asin(15/38));
        }
        translate([0, 51.4*cos(2*asin(15/51.4)/2), 0]) {
          circle_sector(43.0,
                        (270 - 2*asin(15/51.4)/2),
                        (270 - 2*asin(15/51.4)/2) + 2*asin(15/51.4));
        }
      }
    }
  }
}

module 03by_shape(shape_offset = 0) {
  scale([1, 1.015, 1]) offset(r = 0.5) { // Suggested adjustment by 03by user
    offset(r = shape_offset) {
      translate([0, 1.8, 0]) 03by();
    }
  }
}

module fh800_model(shape_offset = 0,
                   perf_offset = 0,
                   perf = false,
                   model = "01by") {

  function y_position(model) = model == "01by" ? 41.9 : 37.8;
  function curve_radius(model) = model == "01by" ? 44.6 : 41;

  module model_perf(perf_offset) {
    offset(perf_offset) {
      translate([0, y_position(model), 0]) {
        smooth_circles_union(number_of_magnets,
                             magnet_diameter,
                             curve_radius(model),
                             filet,
                             printer_tolerance);
      }
    }
  }

  difference() {
    // Call the appropriate function based on model type
    if (model == "01by") {
      01by_shape(shape_offset);
    } else {
      03by_shape(shape_offset);
    }
    if (perf) {
      model_perf(perf_offset);
    }
  }
}

// Clips to lock the tips holder in place
module clips(z_position = clips_height_position) {
  in_offset = -2;
  out_offset = 1.2;
  module clips_extrude(height,
                       inner_offset = in_offset,
                       outer_offset = out_offset,
                       model = "01by",
                       layer_height = layer_height) {

    function base1(model) = model == "01by" ? 41+shape_offset : 44+shape_offset;
    function base2(model) = model == "01by" ? 36+shape_offset : 39+shape_offset;
    function clip_height1(model) = 8.6+shape_offset;
    function clip_height2(model) = 4+shape_offset;
    //function rounding_tolerance(layer_height) = layer_height < 0.25 ? 0.1 : 0.0;

    module clips_face(inner_offset, outer_offset, model) {
      difference() {
        fh800_model(shape_offset = shape_offset + outer_offset,
                    perf_offset = 0,
                    perf = true,
                    model = model);
        fh800_model(shape_offset = shape_offset + inner_offset,
                    perf_offset = 0,
                    perf = true,
                    model = model);
        translate([0, clip_height1(model)/2, 0]) {
          isosceles_trapezium(base1(model),
                              base2(model),
                              clip_height1(model),
                              center = true);
          translate([0, (clip_height1(model)+clip_height2(model))/2, 0]) {
            isosceles_trapezium(base2(model),
                                base2(model)+clip_height2(model),
                                clip_height2(model),
                                center = true);
          }
        }
      }
    }
    
    linear_extrude(height) {
      clips_face(inner_offset, outer_offset, model);
    }
  }

  // Module entry point
  clips_height = 10.2;
  clips_chamfer = 2.2;
  clips_z_position = clips_height_position;

  translate([0, 0, clips_z_position]) {
    difference() {
      // Main extrusion
      clips_extrude(height = clips_height,
                    inner_offset = in_offset,
                    outer_offset = out_offset,
                    model = model,
                    layer_height = layer_height);
   
      // Chamfered edges
      hull() {
        translate([0, 0, clips_height - clips_chamfer]) {
          linear_extrude(0.01) {
            fh800_model(shape_offset = in_offset,
                        perf_offset = 0,
                        perf = false,
                        model = model);
          }
          translate([0, 0, clips_chamfer]) {
            linear_extrude(0.01) {
              fh800_model(shape_offset = clips_chamfer+in_offset,
                          perf_offset = 0,
                          perf = false,
                          model = model);
            }
          }
        }
      }
    }
  }
}

module holder(shape_offset = shape_offset,
              layer_height = layer_height,
              model = model) {
  // First part of the holder: Chamfered retainer
  for (i = [0:layer_height:0.8]) {
    translate([0, 0, i]) {
      linear_extrude(layer_height) {
        fh800_model(shape_offset = shape_offset + i,
                    perf_offset = 0.8 - i,
                    perf = true,
                    model = model);
      }
    }
  }
  // Second part of the holder: Retainer
  translate([0, 0, 0.8]) {
    linear_extrude(0.8) {
      fh800_model(shape_offset = shape_offset + 0.8,
                  perf_offset = 0,
                  perf = true,
                  model = model);
    }
  }
  // Third part of the holder: Tips contaoner
  translate([0, 0, 1.6]) {
    linear_extrude(20) {
      fh800_model(shape_offset = shape_offset,
                  perf_offset = 0,
                  perf = true,
                  model = model);
    }
  }
  // Fourth part of the holder: Separation between tips and magnet section 
  translate([0, 0, 21.6]) {
    linear_extrude(2 * layer_height) {
      fh800_model(shape_offset = shape_offset,
                  perf_offset = 0,
                  perf = false,
                  model = model);
    }
  }
  // Fifth part of the holder: Magnet contianer
  translate([0, 0, 21.6 + 2 * layer_height]) {
    linear_extrude(2.4) {
      fh800_model(shape_offset = shape_offset,
                  perf_offset = 0,
                  perf = true,
                  model = model);
    }
  }
  // Sixth part of the holder: Chmafered magnet contianer
  translate([0, 0, 24 + 2 * layer_height]) {
    for (i = [0:layer_height:1.6]) {
      translate([0, 0, i]) {
        linear_extrude(layer_height) {
          fh800_model(shape_offset = shape_offset - i,
                      perf_offset = 0,
                      perf = true,
                      model = model);
        }
      }
    }
  }
}

module tips_holder() {
  difference() {
    holder();
    clips();
  }
}

// Module entry point
module hakko_fx_888d_magnetic_tips_holder(z_position) {
  if ($preview) {
    color("Gold", 1.0) clips();
    color("Yellow", 1.0) holder();
  } else {
    tips_holder();
    translate([0, -30, -z_position]) {
      clips();
    }
  }
}

hakko_fx_888d_magnetic_tips_holder(clips_height_position);
