// Include the file where the accessory modules are defined
include <ikea_skadis.scad>

/* [Accessory selector] */
selector = "skadis_curved_hook"; // [skadis_curved_hook, skadis_squared_hook, skadis_straight_hook, skadis_o_holder, skadis_u_holder, skadis_squared_holder, skadis_plier, skadis_plate, skadis_round_plate, skadis_box, skadis_round_box, skadis_rack, skadis_bits_serie]

/* [Global parameters] */
all_pegs = false; // [false,true]
fullfill = true; // [false,true]
retainer = false; // [false,true]
nozzle_width = 0.4;
tolerance = 0.6;

/* [skadis_curved_hook parameters] */
// Diameter
skadis_curved_hook_diamter = 20;

/* [skadis_squared_hook parameters] */
skadis_squared_hook_length = 10;
skadis_squared_hook_height = 30;

/* [skadis_straight_hook parameters] */
skadis_straight_hook_length = 60;

/* [skadis_o_holder parameters] */
skadis_o_holder_diameter = 16;

/* [skadis_u_holder parameters] */
skadis_u_holder_diameter = 16;

/* [skadis_squared_holder parameters] */
skadis_squared_holder_lenght = 60;
skadis_squared_holder_width = 20;

/* [skadis_plier parameters] */
skadis_plier_length = 30;
skadis_plier_width = 18;
skadis_plier_filet = 6;

/* [skadis_plate parameters] */
skadis_plate_lenght = 80;
skadis_plate_width = 60;

/* [skadis_round_plate parameters] */
skadis_round_plate_diameter = 80;

/* [skadis_box parameters] */
skadis_box_length = 60;
skadis_box_width = 40;
skadis_box_height = 30;
skadis_box_filet = 6;

/* [skadis_round_box parameters] */
skadis_round_box_diameter = 30;
skadis_round_box_height = 40;

/* [skadis_rack parameters] */
skadis_rack_diameter_default = undef;
skadis_rack_diameter1 = 6;
skadis_rack_diameter2 = 22;
skadis_rack_number_of_units = 6;
skadis_rack_compact = false;

/* [skadis_bits_serie parameters] */
skadis_bits_serie_height = 22;
skadis_bits_serie_diameter = 8;
skadis_bits_serie_step = 2;
skadis_bits_serie_number_of_bits = 12;
skadis_bits_serie_number_of_facets = 36;
skadis_bits_serie_angle = 0;
skadis_bits_serie_bottom = true;
skadis_bits_serie_tolerance1 = 0.6;
skadis_bits_serie_tolerance2 = 0.6;
skadis_bits_serie_compact = false;

// Check each accessory option and call the corresponding module
module render_accessory(selector) {
    if (selector == "skadis_curved_hook") {
      skadis_curved_hook(skadis_curved_hook_diamter,
                         fullfill,
                         retainer);
    } else if (selector == "skadis_squared_hook") {
      skadis_squared_hook(skadis_squared_hook_length,
                          skadis_squared_hook_height,
                          fullfill,
                          retainer);
    } else if (selector == "skadis_straight_hook") {
      skadis_straight_hook(skadis_straight_hook_length,
                           fullfill,
                           retainer);
    } else if (selector == "skadis_o_holder") {
      skadis_o_holder(skadis_o_holder_diameter,
                      all_pegs,
                      fullfill,
                      retainer);
    } else if (selector == "skadis_u_holder") {
      skadis_u_holder(skadis_u_holder_diameter,
                      all_pegs,
                      fullfill,
                      retainer);
    } else if (selector == "skadis_squared_holder") {
      skadis_squared_holder(skadis_squared_holder_lenght,
                            skadis_squared_holder_width,
                            all_pegs,
                            fullfill,
                            retainer);
    } else if (selector == "skadis_plier") {
      skadis_plier(skadis_plier_length,
                   skadis_plier_width,
                   skadis_plier_filet,
                   all_pegs,
                   fullfill,
                   retainer);
    } else if (selector == "skadis_plate") {
      skadis_plate(skadis_plate_lenght,
                   skadis_plate_width,
                   all_pegs,
                   fullfill,
                   retainer);
    } else if (selector == "skadis_round_plate") {
      skadis_round_plate(skadis_round_plate_diameter,
                         all_pegs,
                         fullfill,
                         retainer);
    } else if (selector == "skadis_box") {
      skadis_box(skadis_box_length,
                 skadis_box_width,
                 skadis_box_height,
                 tolerance,
                 skadis_box_filet,
                 all_pegs,
                 fullfill,
                 retainer);
    } else if (selector == "skadis_round_box") {
      skadis_round_box(skadis_round_box_diameter,
                       skadis_round_box_height,
                       tolerance,
                       all_pegs,
                       fullfill,
                       retainer);
    } else if (selector == "skadis_rack") {
      skadis_rack(skadis_rack_diameter_default,
                  skadis_rack_diameter1,
                  skadis_rack_diameter2,
                  skadis_rack_number_of_units,
                  skadis_rack_compact,
                  all_pegs,
                  fullfill,
                  retainer);
    } else if (selector == "skadis_bits_serie") {
      skadis_bits_serie(skadis_bits_serie_height,
                        skadis_bits_serie_diameter,
                        skadis_bits_serie_step,
                        skadis_bits_serie_number_of_bits,
                        skadis_bits_serie_number_of_facets,
                        skadis_bits_serie_angle,
                        skadis_bits_serie_bottom,
                        skadis_bits_serie_tolerance1,
                        skadis_bits_serie_tolerance2,
                        skadis_bits_serie_compact,
                        all_pegs,
                        fullfill,
                        retainer);
    } else {
      echo("Invalid accessory selector:", selector);
    }
}

// Call the module to render the selected accessory
render_accessory(selector);

