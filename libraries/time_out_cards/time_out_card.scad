/*
time_out_card.scad  

This script generates customizable time-out cards for handball matches, following the official handball rules. 
Each team (Home and Away) is allowed one time-out per period, including overtime. 
The script produces designs for these cards with the following output options:
  - SVG files: For use with vinyl cutters or laser engravers.
  - STL files: For 3D printing in various configurations, such as multi-color cards or stencils.
*/

use <extra.scad>

// Default redering resolution
$fa = $preview ? 2 : 1; // default minimum facet angle
$fs = $preview ? 1 : 0.5; // default minimum facet size

/* [Printer settings] */
layer_height = 0.20; // [0.10, 0.15, 0.20, 0.25]

/* [Card dimensions] */
width = 150;
length = 210;
minimum_thickness = 1.0;
fillet = 6;

/* [Text] */
char_font = "FreeSerif:style=Normal";
char_size = 36;
margin = 12;
// Time-Out character
char_time_out = "T"; // [T]
// 1st, 2nd, 3rd or extra time
char_period = "1"; // ["1", "2", "3", "E"]
// Away team or home team
char_team = "A"; // ["A", "H"]

/* [Card type] */
show_details = true;

/* [Parts] */
selector = "svg"; // ["svg", "stencil", "card", "card_text"]

// Functions
function boundary(w = width, l = length, m = margin) =
    [w-2*m, l-2*m];

boundary = boundary(); // Compute boundary

function layers(t = minimum_thickness, l = layer_height) =
    ceil(t/l);

layers = layers();

// Modules
module bland_card_sketch(w = width, l = length) {
    fillet_reflex_angles(fillet)
        square([w, l], center = true);
}

module text_time_out(w = boundary[0], l = boundary[1]) {
    horizontal_postion = w/2;
    vertical_position = -l/4;
    
    resize([w, l]) {
        text(char_time_out, valign = "center", halign = "center", font = char_font);
    }
    if (show_details) {
        translate([-horizontal_postion, vertical_position]) {
            text(str(char_period), valign = "center", halign = "left",
                 font = char_font, size = char_size);
        }
        translate([horizontal_postion, vertical_position]) {
            text(char_team, valign = "center", halign = "right",
                 font = char_font, size = char_size);
        }
    }
}

// "svg" module is suitable for vinyl cutter
module svg() {
    text_time_out();
}

// "stencil" module is suitable for creating stensil using stencil compatible font
module stencil(l = layers*layer_height) {
    linear_extrude(l) {
        difference() {
            bland_card_sketch();
            text_time_out();
        }
    }
}

// "card" and "card_text" are suitable for multicolor 3D prints
module card_text() {
    shift = layers%2 != 0 ? layer_height/2 : 0;
    for (i = [0:1]) {
        rotate([0, i*180, 0])
            translate([0, 0, shift])
            linear_extrude(floor(layers/2)*layer_height)
            text_time_out();
    }
}

module card() {
    difference() {
        linear_extrude(layers*layer_height, center = true) bland_card_sketch();
        card_text();
    }
}

module main(s = selector) {
    if (s == "svg") {
        color("LightGrey", 1.0) svg();
    }
    else if (s == "stencil") {
        color("DarkGrey", 1.0) stencil();
    }
    else if (s == "card") {
        color("Green", 1.0) card();
    }
    else {
        color("White", 1.0) card_text();
    }
}

main();
