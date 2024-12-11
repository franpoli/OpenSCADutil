/*
magnetic_card_display_holder.scad

This OpenSCAD script generates a customizable stand designed to hold cards
securely using magnets. The stand is designed to adjust based on the thickness
of the cards, ensuring a snug fit.
*/

use <extra.scad>

// Default redering resolution
$fa = $preview ? 2 : 1; // default minimum facet angle
$fs = $preview ? 1 : 0.5; // default minimum facet size

/* [Print settings] */
printer_tolerance = 0.1;
nozzel_width = 0.4;
number_of_perimeters = 3;
// Print orientation
lying_down = true;

/* [Hardware] */
magnet_diameter = 8;
magnet_height = 4;
number_of_magnets = 3;
card_width = 150;
card_thickness = 1;
claim_depth = 8; // Depth the holder grips the card's bottom
    
/* [Parts] */
selector = "stand"; // ["stand", "holder", "all"]

// Functions
function wall_width(perimeters = number_of_perimeters,
                    width = nozzel_width) =
    perimeters * width;

wall_width = wall_width(); // Compute wall with

function fillet(width = wall_width(),
               thickness = card_thickness/2) =
    ceil((magnet_height+printer_tolerance)/sqrt(5) + width + thickness);

fillet = fillet(); // Compute bezel

function base(bezel = fillet,
              wall = wall_width,
              diameter = magnet_diameter,
              heigth = magnet_height,
              tolerance = printer_tolerance) =
    3 * (5 * wall + 3 * tolerance + diameter + heigth/2);

base = base(); // Compute bezel

function minimum_claim_depth(desired_value = claim_depth,
                          heigth = magnet_height + wall_width + printer_tolerance) =
    desired_value < heigth ? heigth : desired_value;

minimum_claim_depth = minimum_claim_depth(); // Compute minimum claim_depthing

function conditional_position(boolean) =
    boolean ? 1/3 : 0;

conditional_position = conditional_position(lying_down);

// Magnet's substraction volumes
module magnets(diameter = magnet_diameter + 2 * printer_tolerance,
               height = 2 * (magnet_height + printer_tolerance)) {
    for (i = [1:number_of_magnets]) {
        shift_position = card_width/number_of_magnets/2;
        rotate([0, 90, 0]) translate([-i*(card_width/number_of_magnets)+shift_position,
                                      base /6 - height / 6,
                                      -height / 2])
            cylinder(h = height, d = diameter);
    }
}

module main_2d_shape(boolean = lying_down) {
    
    radius = sqrt(pow((base/2),2) + pow((base/4),2));
    
    module shape() { 
        fillet_reflex_angles(fillet) difference() {
            circle(r=radius, $fn=3);
            translate([minimum_claim_depth, -base/2, 0]) square(base);
            translate([0, 0, 0]) square([radius, printer_tolerance]);
        }
    }

    // Cut the base for laying printing
    difference() {
        color("Blue", 0.5) shape();
        color("Red", 0.5) translate([-3/2*radius+conditional_position*fillet, -base/2, 0])
            square([radius, base]);
    }
}

module parts(part = selector) {

    module make_part(is_difference, sign) {
        if (is_difference) {
            difference() {
                linear_extrude(card_width) difference() {
                    main_2d_shape();
                    shape_modifier(sign);
                }
                magnets();
            }
        } else {
            difference() {
                linear_extrude(card_width) intersection() {
                    main_2d_shape();
                    shape_modifier(sign);
                }
                magnets();
            }
        }
    }

    module shape_modifier(sign) {
        translate([sign * printer_tolerance / 2,
                   sign * printer_tolerance / 2,
                   0])
            square(base / 2);        
    }

    module holder() {
        make_part(false, 1); // Intersection with positive tolerance
    }

    module stand() {
        make_part(true, -1); // Difference with negative tolerance
    }

    // Conditional rendering and positioning
    rotate([0, -270 * conditional_position, 0]) translate([0, 0, -card_width / 2]) {
        if (part == "holder") {
            color("RosyBrown", 1.0) holder();
        } else if (part == "stand") {
            color("Tan", 1.0) stand();
        } else {
            color("RosyBrown", 1.0) holder();
            color("Tan", 1.0) stand();
        }
    }
}

parts(part = selector);

// Debug
echo("wall_width", wall_width);
echo("fillet", fillet);
echo("base)", base);
echo("minimum_claim_depth", minimum_claim_depth);
echo("conditional_position", conditional_position);
