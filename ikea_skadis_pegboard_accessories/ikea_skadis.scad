/*
 * ikea_skadis.scad - IKEA Skådis pegboard library to generate 3D printable accessories
 * by François Polito
 * created 2020-07-17
 * updates:
 * 2020-08-12
 * - skadis_plier module fixed length reporting to skadis_pegs_position module
 * - modified the function filet_limits to works better with new comming modules
 * - added the skadis_bits_serie module
 * OpenSCAD version 2019.05 
 * This work is licensed under the Creative Commons - Attribution - Non-Commercial - ShareAlike license.
 * https://creativecommons.org/licenses/by-nc-sa/4.0/
 */
 
 // Resolution variables
$fa=2; // default minimum facet angle
$fs=0.5; // default minimum facet size

// 3D printer parameters
nw = 0.4; // nozzle width
tol = 0.6; // 3D printer tolerance

// Pegs and pegboard parameters
pdw = 5; // peg default width
pdt = 4.6; // peg default thickness
dbp = 40; // distance between pegs

// pegs options
ap = false; // all_pegs [false/true] defines whether or not all pegs should be generated
ff = true; // fullfill [false/true] defines wether ot not a peg should be full filled
ret = false; // retainer [false/true] defines wether ot not if a retainer should be added to avoid pegs falling out easily

// Optimal dimensions
lh = (nw / 2); // layer height (half the nozzle width)
pw = floor(pdw / nw) * nw; // peg width (a multiple of the nozzle width)
pt = floor(pdt / lh) * lh; // peg thickness (a multiple of the layer height)
ptw = 3*pw; // peg total width
ptl = 4*pw; // peg total length

// Output in the console the recommended print settings for fuse filament printers
echo("Recommended print settings:");
echo("--> Nozzle width", nw);
echo("--> Layer height", lh);
echo("--> Perimeters", ceil((pw/nw)/2));

// functions
function chamfer() = floor(0.2*pw/nw)*nw;
function minimum_wall() = ceil(1.2/nw)*nw;
function filet_limits(l, w, filet) = min(l, w) < filet ?
    min(l, w)/2 : filet/2 < tol+minimum_wall()+0.1 ?
        tol+minimum_wall()+0.1 : filet/2;
function is_odd(int) = int%2;
        
//echo("filet_limits", filet_limits(l = 40.9468, w = 28.5, filet = 16.6+2*tol));

/* Peg positionning requires two parameters:
 * 1. length (numerical)
 *    Computes the positionning of the peg(s) according to accessory length.
 * 2. all_pegs (boolean)
 *    Set to false; a minimal number of pags will be generated. If the value is set to true
 *    all possible possible pegs will be generated for stronger support.
 */
module skadis_pegs_position(length = 0, all_pegs) {
    translate([-(length-(length%dbp))/2, 0, 0]) {
        if ( all_pegs == true ) {
            for (x = [0 : dbp : length]) { translate([x, 0, 0]) { children(); } }
        } else {
            for (x = [0 : (length < dbp ? dbp : length-(length%dbp)) : length]) { translate([x, 0, 0]) { children(); } }
        }
    }
}

/* A peg takes up to two parameters:
 * 1. fullfill (boolean)
 *    Set to true a solid peg will be generated, possibly stronger and easier to print.
 *    The value set to false a lighter peg will be generated
 * 2. retainer (boolean)
 *    Set to true, the top of the peg will be larger and hold better on the pegboard.
 *    Set to false the peg will be more easily moved around on the pegboard but will
 *    more easily fallout when lifting the peg
 */
module skadis_peg(fullfill, retainer) {
    union() {
        intersection() {
            translate([-pt/2, -pw, 0]) {
                cube([pt, ptw, ptl]);
            }
            difference() {
                hull() {
                    translate([-pt/2, ptw-2*pw, ptl-pw]) { cube(size = [pt, pw, pw], center = false); }
                    translate([-pt/2, (ptw-pw)-2*pw, 2*pw/sqrt(2)]) { rotate([0, 90, 0]) cylinder(h = pt, r = 2*pw, center = false); }
                }
                hull() {
                    translate([-pt/2, -pw, ptl-pw]) cube(size = [pt, pw, pw], center = false);
                    translate([-pt/2, -2*pw, pw]) cube(size = [pt, pw, pw], center = false);
                    translate([-pt/2, ptw-3*pw, ptl-pw]) cube(size = [pt, pw, pw], center = false);
                }
                if (fullfill == false) {
                    difference() {
                        hull() {
                            translate([-pt/2, (ptw-pw)-2*pw, 2*pw/sqrt(2)]) { rotate([0, 90, 0]) cylinder(h = pt, r = 1.5*pw, center = false); }
                            translate([-pt/2, pw/2, 2*pw]) cube(size = [pt, pw, pw], center = false);
                        }
                        hull() {
                            translate([-pt/2, -pw, pw]) rotate([0, 90, 0]) cylinder(h = pt, r = pw, center = false);
                            translate([-pt/2, pw, 3*pw]) rotate([0, 90, 0]) cylinder(h = pt, r = pw, center = false);
                            translate([-pt/2, -pw, 3*pw]) cube(size = [pt, pw, pw], center = false);
                        }
                        translate([-pt/2, -pw, -pw/2]) cube(size = [pt, 3*pw, pw], center = false);
                    }
                }
            }
        }
        if (retainer == true) {
            hull() {
                translate([-pt/2, pw, 3*pw]) cube(size = [pt, pw, pw]);
                translate([-pt/2+chamfer(), pw, 3*pw+chamfer()]) cube(size = [pt, pw, pw-8*lh]);
            }
        }
    }
}

/* Screw driver holder hole can be define with either one or two diameter:
 * 1. default and unique considered diameter
 * 2. diameter 1 for the handle
 * 3. diameter 2 for the shank or blade
 */
module skadis_driver_hole(d, d1, d2) {
    if (d == undef) {
        union() {
            translate([0, 0, pw-chamfer()]) cylinder(h = chamfer(), d1 = d1, d2 = d1+2*chamfer());
            translate([0, 0, pw-(floor(pw/2/lh)*lh)]) cylinder(h = floor(pw/2/lh)*lh, d = d1);
            cylinder(h = pw-(floor(pw/2/lh)*lh), d = d2);
        }
    }
    else {
        union() {
            translate([0, 0, pw-chamfer()]) cylinder(h = chamfer(), d1 = d, d2 = d+2*chamfer());
            cylinder(h = pw, d = d);
        }
    }
}

/*
 * A curved hook takes up to three parameters:
 * 1. d (numerical) - the inner diameter of the curved hook
 * 2. fullfill (boolean)
 * 3. retainer (boolean)
 */
module skadis_curved_hook(d = 20, fullfill = ff, retainer = ret) {
    translate([0, 0, pt/2]) rotate([0, -90, 0]) union() {
        translate([-pt/2, -(d+2*pw)/2, 0]) {
            difference() {
                rotate([0, 90, 0]) cylinder(h = pt, r = (d+2*pw)/2, center = false);
                rotate([0, 90, 0]) cylinder(h = pt, r = d/2, center = false);
                translate([0, -(d+2*pw)/2, 0]) cube(size = [pt, d+2*pw, (d+2*pw)/2]);
            }
            translate([0, -(d+2*pw)/2, 0]) cube(size = [pt, pw, pw/2]);;
            translate([0, -(d+pw)/2, pw/2]) rotate([0, 90, 0]) cylinder(h = pt, d = pw, center = false);
        }
        skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}

/* A straight hook takes up to three parameters:
 * 1. l (numerical) - the length of th straight hook
 * 2. fullfill (boolean)
 * 3. retainer (boolean)
 */
module skadis_straight_hook(l = 60, fullfill = ff, retainer = ret) {
    translate([0, 0, pt/2]) rotate([0, -90, 0]) union() {
        translate([-pt/2, -(l+2*pw), 0]) cube(size = [pt, l+2*pw, pw]);
        translate([-pt/2, -(l+1.5*pw), pw]) rotate([0, 90, 0]) cylinder(h = pt, d = pw, center = false);
        translate([-pt/2, -pw, -l/5]) cube(size = [pt, pw, l/4]);
        if (l/5 > 1.5*pw) {
            hull() {
                translate([-pt/2, -pw, -l/5]) cube(size = [pt, (5*pw/sqrt(26))/4, 5*pw/sqrt(26)]);
                translate([-pt/2, -l-pw, 0]) cube(size = [pt, (5*pw/sqrt(26))/4, 5*pw/sqrt(26)]);
            }
        }
        skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}

/* A O-profile takes up to four parameters:
 * 1. d (numerical) - Inner diameter
 * 2. all_pegs (boolean)
 * 3. fullfill (boolean)
 * 4. retainer (boolean)
 */
module skadis_o_holder(d = 16, all_pegs = ap, fullfill = ff, retainer = ret) {
        union() {
        difference() {
            union() {
                translate([0, -(2*pw+d/2)/2, pw/2]) cube(size = [d+2*pw, 2*pw+d/2, pw], center = true);
                translate([0, -d/2-2*pw, 0]) cylinder(h = pw, d = d+2*pw, center = false);
            }
            translate([0, -d/2-2*pw, 0]) cylinder(h = pw, d = d, center = false);
            translate([0, -d/2-2*pw, pw-chamfer()]) cylinder(h = chamfer(), d1 = d, d2 = d+2*chamfer(), center = false);
        }
        skadis_pegs_position(length = d+2*pw, all_pegs = all_pegs) skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}
//skadis_o_holder(d = 122, all_pegs = true);

/* A U-profile takes up to four parameters:
 * 1. d (numerical) - Inner diameter
 * 2. all_pegs (boolean)
 * 3. fullfill (boolean)
 * 4. retainer (boolean)
 */
module skadis_u_holder(d = 16, all_pegs = ap, fullfill = ff, retainer = ret) {
    union() {
        difference() {
            translate([0, -(3*pw+d)/2, pw/2]) cube(size = [d+2*pw, 3*pw+d, pw], center = true);
            hull() {
                translate([0, -d/2-2*pw, 0]) cylinder(h = pw, d = d, center = false);
                translate([0, -(3*pw+d), 0]) cylinder(h = pw, d = d-8*lh, center = false);
            }
            hull() {
                translate([0, -d/2-2*pw, pw-chamfer()]) cylinder(h = chamfer(), d1 = d, d2 = d+8*lh, center = false);
                translate([0, -(3*pw+d), pw-chamfer()]) cylinder(h = chamfer(), d1 = d-2*chamfer(), d2 = d, center = false);
            }
        }
        skadis_pegs_position(length = d+2*pw, all_pegs = all_pegs) skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}

/* A plier takes up to six parameters:
 * 1. l (numerical) - length
 * 2. w (numerical) - width
 * 3. filet (numerical)
 * 4. all_pegs (boolean)
 * 5. fullfill (boolean)
 * 6. retainer (boolean)
 */
module skadis_plier(l = dbp+pt-2*pw, w = dbp/2, filet = chamfer(), all_pegs = ap, fullfill = ff, retainer = ret) {
    union() {
        difference() {
            hull() {
                translate([0, -(pw/2), pw/2]) cube(size = [l+2*pw, pw, pw], center = true);
                for (x = [0:1:1]) {
                    mirror([x, 0, 0]) translate([l/2-filet_limits(l, w, filet), -(w-filet_limits(l, w, filet)+2*pw), 0]) cylinder(h = pw, r = filet_limits(l, w, filet)+pw);
                }
            }
            translate([0, -(w/2+2*pw), 0]) hull() for (y = [0:1:1]) {
                mirror([0, y, 0]) for (x = [0:1:1]) {
                    mirror([x, 0, 0]) translate([l/2-filet_limits(l, w, filet), w/2-filet_limits(l, w, filet), 0]) cylinder(h = pw, r = filet_limits(l, w, filet));
                }
            }
            hull() {
                translate([0, -(w/2+2*pw), 0]) hull() for (y = [0:1:1]) {
                    mirror([0, y, 0]) for (x = [0:1:1]) {
                        mirror([x, 0, 0]) translate([l/2-filet_limits(l, w, filet), w/2-filet_limits(l, w, filet), pw-chamfer()]) cylinder(h = chamfer(), r = filet_limits(l, w, filet));
                    }
                }
                translate([0, -(w/2+2*pw), 0]) hull() for (y = [0:1:1]) {
                    mirror([0, y, 0]) for (x = [0:1:1]) {
                        mirror([x, 0, 0]) translate([l/2-filet_limits(l, w, filet), w/2-filet_limits(l, w, filet), pw]) cylinder(h = chamfer(), r = filet_limits(l, w, filet)+chamfer());
                    }
                }
            }
        }
        skadis_pegs_position(length = l+pw, all_pegs = all_pegs) skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}

/* A plate takes up to five parameters:
 * 1. l (numerical) - length
 * 2. w (numerical) - width
 * 3. all_pegs (boolean)
 * 4. fullfill (boolean)
 * 5. retainer (boolean)
 */
module skadis_plate(l = 80, w = 60, all_pegs = ap, fullfill = ff, retainer = ret) {
    union() {
        difference() {
            hull() {
                translate([0, -pw/2, pw/2]) cube(size = [l+16*lh, pw, pw], center = true);
                for (x = [0:1:1]) {
                    mirror([x, 0, 0]) translate([(l/2)-pw+chamfer(), -(w+chamfer()+pw), 0]) cylinder(h = pw, r = pw+chamfer());
                }
            }
            translate([0, -(w/2+2*pw), 0]) hull() {
                for (y = [0:1:1]) {
                     mirror([0, y, 0]) for (x = [0:1:1]) {
                        mirror([x, 0, 0]) translate([(l/2)-pw, -((w/2)-pw), pw-chamfer()/2]) cylinder(h = chamfer()/2, r1 = pw - chamfer()/2, r2 = pw);
                    }
                }
            }
        }
        skadis_pegs_position(length = l+16*lh-pt, all_pegs = all_pegs) skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}

/* A plate takes up to five parameters:
 * 1. d (numerical) - diameter
 * 2. all_pegs (boolean)
 * 3. fullfill (boolean)
 * 4. retainer (boolean)
 */
module skadis_round_plate(d = 80, all_pegs = ap, fullfill = ff, retainer = ret) {
    union() {
        difference() {
            hull() {
                translate([0, -pw/2, pw/2]) cube(size = [d+16*lh, pw, pw], center = true);
                translate([0, -((d+16*lh)/2+2*pw), 0]) cylinder(h = pw, d = d+16*lh);
            }
            hull() {
                translate([0, -((d+16*lh)/2+2*pw), pw]) cylinder(h = chamfer()/2, d = d);
                translate([0, -((d+16*lh)/2+2*pw), pw-chamfer()/2]) cylinder(h = chamfer()/2, d = d-chamfer()/2);
            }
        }
        skadis_pegs_position(length = d+16*lh-pt, all_pegs = all_pegs) skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}

/* A box takes up to 8 parameters:
 * 1. l (numerical) - length
 * 2. w (numerical) - width
 * 3. h (numerical) - heigth
 * 4. t (numerical) - tolerance
 * 5. fillet (numerical)
 * 6. all_pegs (boolean)
 * 7. fullfill (boolean)
 * 8. retainer (boolean)
 */
module skadis_box(l = 60, w = 40, h = 30, t = tol, filet = pw, all_pegs = ap, fullfill = ff, retainer = ret) {
    function my_filet() = filet_limits(l, w, filet);
    translate([0, -w/2-(2*pw+t+minimum_wall()), 0]) {
        difference() {
            union() {
                hull() for (y = [0:1:1]) {
                    mirror([0, y, 0]) {
                        for (x = [0:1:1]) {
                            mirror([x, 0, 0]) {
                                translate([l/2-(my_filet()), w/2-(my_filet()), 0]) {
                                    translate([0, 0, h+2-3*chamfer()]) cylinder(h = 2*chamfer(), r = my_filet()+minimum_wall()+2*chamfer());
                                    translate([0, 0, h+2-5*chamfer()]) cylinder(h = 2*chamfer(), r = my_filet()+minimum_wall());
                                }
                            }
                        }
                    }
                }
                hull() for (y = [0:1:1]) {
                    mirror([0, y, 0]) {
                        for (x = [0:1:1]) {
                            mirror([x, 0, 0]) {
                                translate([l/2-(my_filet()), w/2-(my_filet()), 0]) {
                                    cylinder(h = h+minimum_wall()-4*chamfer(), r = my_filet()+minimum_wall());
                                }
                            }
                        }
                    }
                }
            }
            hull() for (y = [0:1:1]) {
                mirror([0, y, 0]) {
                    for (x = [0:1:1]) {
                        mirror([x, 0, 0]) {      
                            translate([l/2-(my_filet()), w/2-(my_filet()), minimum_wall()])
                            cylinder(h = h, r = my_filet());
                        }
                    }
                }
            }
        }
    }
    skadis_plier(l = l+2*(t+minimum_wall()), w = w+2*(t+minimum_wall()), filet = 2*my_filet()+2*(t+minimum_wall()), all_pegs = all_pegs, fullfill = fullfill, retainer = retainer);
}

//translate([0,-(15+2*pw+tol+minimum_wall()),0]) color("Red", 0.5) cube(size = [40, 30, 2*pw], center = true);
//skadis_plier(40, 30);
 
/* A round box takes up to 6 parameters:
 * 1. d (numerical) - diameter
 * 2. h (numerical) - heigth
 * 3. t (numerical) - tolerance
 * 4. all_pegs (boolean)
 * 5. fullfill (boolean)
 * 6. retainer (boolean)
 */
module skadis_round_box(d = 30, h = 40, t = tol, all_pegs = ap, fullfill = ff, retainer = ret) {
    translate([0, -(d/2+2*pw+minimum_wall()+t), 0]) difference() {
        union() {
            cylinder(h = h-2*minimum_wall(), d = d+2*minimum_wall());
            translate([0, 0, h-chamfer()]) cylinder(h = chamfer()+minimum_wall(), d = d+2*minimum_wall()+4*chamfer());
            translate([0, 0, h-2*minimum_wall()]) cylinder(h = 2*chamfer(), d1 = d+2*minimum_wall(), d2 = d+2*minimum_wall()+4*chamfer());
        }
        translate([0, 0, minimum_wall()]) cylinder(d = d, h = h);
    }
    skadis_o_holder(d = d+2*(minimum_wall()+t), all_pegs = all_pegs, fullfill = fullfill, retainer = retainer);
}

/* A skadis rack takes up to heigth parameters
 * 1. d (numerical) - the unique diameter to be used
 * 2. d1 (numerical) - 1st diameter
 * 3. d2 (numerical) - 2nd diameter
 * 4. n (numerical) - number of units
 * 5. compact (boolean) - if set to true the generated rack will be shorter
 * 6. all_pegs (boolean)
 * 7. fullfill (boolean)
 * 8. retainer (boolean)
 */
module skadis_rack(d, d1 = 20, d2 = 10, n = 6, compact = false, all_pegs = ap, fullfill = ff, retainer = ret) {
    function rack_length() = (compact) ? ((d == undef) ? ((n+1)*(d1+pw)/2)+pw : ((n+1)*(d+pw)/2)+pw) : ((d == undef) ? (n*(d1+pw))+pw : (n*(d+pw))+pw);
    union() {
        difference() {
            hull() {
                translate([0, -pw/2, pw/2]) cube(size = [rack_length(), pw, pw], center = true);
                for (x = [0:1:1]) mirror([x, 0, 0]) {
                    translate([
                        (d == undef) ? (rack_length()-(d1+2*pw))/2 : (rack_length()-(d+2*pw))/2,
                        (compact) ? (d == undef)?-(2*pw+d1/2+(d1+pw)/2*sqrt(3)):-(2*pw+d/2+(d+pw)/2*sqrt(3)) : (d == undef)?-(2*pw+d1/2):-(2*pw+d/2),
                        0]) cylinder(h = pw, d = ((d == undef) ? d1+2*pw : d+2*pw));
                }
            }
            translate([
                (compact) ? ((d == undef) ? -((n-1)*(d1+pw)/4) : -((n-1)*(d+pw)/4)) : ((d == undef) ? -((n-1)*(d1+pw)/2) : -((n-1)*(d+pw)/2)),
                (d == undef) ? -(d1/2+2*pw) : -(d/2+2*pw),
                0]) {
                if (compact == false) {
                    for (x = [0:1:n-1]) {
                        if (d == undef) {
                            translate([x*(d1+pw), 0, 0]) skadis_driver_hole(d = d, d1 = d1, d2 = d2);
                        }
                        else {
                            translate([x*(d+pw), 0, 0]) skadis_driver_hole(d);
                        }
                    }
                }
                else { 
                    for (x = [0:1:n-1]) {
                        if (d == undef) {
                            translate([x*(d1+pw)/2, -(d1+pw)/2*sqrt(3)*(x%2), 0]) skadis_driver_hole(d = d, d1 = d1, d2 = d2);
                        }
                        else {
                            translate([x*(d+pw)/2, -(d+pw)/2*sqrt(3)*(x%2), 0]) skadis_driver_hole(d);
                        }
                    }
                }
            }
        }
        skadis_pegs_position(length = rack_length()-pt, all_pegs = all_pegs) skadis_peg(fullfill = fullfill, retainer = retainer);
    }
}

/* A skadis incrementedbits takes up to 13 parameters
 * 1. h (numerical) - the heigth of the bits holder
 * 2. d (numerical) - the diameter of the first bit
 * 3. step (numerical) - the incrementation step for each successive bit
 * 4. n (numerical) - the number of bits the holder shall contain
 * 5. facets (numerical) - the number of sides of the regular polygon (e.g. use 4 a square key, 6 for a hex key)
 * 6. angle (numerical) - provide a way to orient regular polygons
 * 7. bootom (bollean) - set to true each bit will have a bottom holder, set to false a pocket is generated through all the holder
 * 8. tolerance1 (numerical) - the tolerance allowing the container to slide easily through its support
 * 9. tolerance2 (numerical) - the tolerance allowing each bit to slide into a pocket
 * 10. compact (boolean) - set to true, the generated holder will be shorter
 * 11. all_pegs (boolean)
 * 12. fullfill (boolean)
 * 13. retainer (boolean)
*/
module skadis_bits_serie(h = 28, d = 2, step = 1, n = 12, facets = 36, angle = 0, bottom = true, tolerance1 = tol, tolerance2 = tol, compact = false, all_pegs = ap, fullfill = ff, retainer = ret) {
    last_diameter = (n-1)*step+d;
    filet = last_diameter+2*pw;
    skadis_bits_length = (compact) ?
        ((1/2)*n*(2*d+(n-1)*step)+(n-1)*pw-((d+last_diameter)/2))/(n-1)*((n-1)*sqrt(1/3))+pw+d/2+last_diameter/2+pw :
        (1/2)*n*(2*d+(n-1)*step)+(n+1)*pw;
    skadis_bits_width = (compact) ? 2*last_diameter+3*pw : last_diameter+2*pw;
    holder_heigth = (bottom) ? h+minimum_wall() : h;
    translate([-skadis_bits_length/2, -((last_diameter+2*pw)/2+2*pw+tolerance1), 0]) difference() {
        union () {
            hull() {
                hull() {
                    translate([(last_diameter+2*pw)/2, 0, holder_heigth-2*chamfer()])
                        cylinder(h = 2*chamfer(), d = last_diameter+2*(pw+2*chamfer()));
                    translate([(last_diameter+2*pw)/2, 0, holder_heigth-4*chamfer()])
                        cylinder(h = 2*chamfer(), d = last_diameter+2*pw);
                }
                if (compact == false) {
                    hull() { //last_diameter/2+pw
                        translate([skadis_bits_length-(last_diameter/2+pw), 0, holder_heigth-2*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*(pw+2*chamfer()));
                        translate([skadis_bits_length-(last_diameter/2+pw), 0, holder_heigth-4*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*pw);
                    }
                }
                else {
                    hull() {
                        translate([(last_diameter+2*pw)/2, -(last_diameter+pw), holder_heigth-2*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*(pw+2*chamfer()));
                        translate([(last_diameter+2*pw)/2, -(last_diameter+pw), holder_heigth-4*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*pw);
                    }
                    hull() {
                        translate([skadis_bits_length-(last_diameter/2+pw), -(last_diameter+pw), holder_heigth-2*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*(pw+2*chamfer()));
                        translate([skadis_bits_length-(last_diameter/2+pw), -(last_diameter+pw), holder_heigth-4*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*pw);
                    }
                    hull() {
                        translate([skadis_bits_length-(last_diameter/2+pw), 0, holder_heigth-2*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*(pw+2*chamfer()));
                        translate([skadis_bits_length-(last_diameter/2+pw), 0, holder_heigth-4*chamfer()])
                            cylinder(h = 2*chamfer(), d = last_diameter+2*pw);
                    }
                }
            }
            hull() {
                translate([(last_diameter+2*pw)/2, 0, 0])
                    cylinder(h = holder_heigth, d = last_diameter+2*pw);
                if (compact == false) {
                    translate([skadis_bits_length-(last_diameter+2*pw)/2, 0, 0])
                        cylinder(h = holder_heigth, d = last_diameter+2*pw);
                }
                else {
                    translate([(last_diameter+2*pw)/2, -(last_diameter+pw), 0])
                        cylinder(h = holder_heigth, d = last_diameter+2*pw);
                    translate([skadis_bits_length-(last_diameter/2+pw), -(last_diameter+pw), 0])
                        cylinder(h = holder_heigth, d = last_diameter+2*pw);
                    translate([skadis_bits_length-(last_diameter/2+pw), 0, 0])
                        cylinder(h = holder_heigth, d = last_diameter+2*pw);
                    
                }
            }
        }
        // +0.01 safety measure to ensure number of steps against rounding issue
        translate([d/2+pw, 0, 0]) for (diameter = [d:step:d+(n-1)*step+0.01]) {
            count = round((diameter-d)*(1/step));
            distance = count * (diameter-(count*step/2)+pw);
            echo("skadis_bits_serie -> diameter", count+1, "=", diameter, "+", tolerance2, "Is odd?", is_odd(count), "count%2:", count%2);
            translate([(compact) ? distance*sqrt(1/3) : distance,
                (compact) ? -(last_diameter+pw)*is_odd(count) : 0,
                (bottom) ? minimum_wall() : 0])
                rotate([0, 0, angle])
                    cylinder(h = h, d = diameter+tolerance2, center = false, $fn = facets);
        }
    }
    skadis_plier(l = skadis_bits_length+2*tolerance1, w = skadis_bits_width+2*tolerance1, filet = filet+2*tolerance1, all_pegs = all_pegs, fullfill = fullfill, retainer = retainer);
}



// Curved hooks demmo
//skadis_curved_hook(fullfill = false);
//translate ([30, 0, 0]) skadis_curved_hook(fullfill = false);
//translate ([60, 0, 0]) skadis_curved_hook(fullfill = false, retainer = true);
//translate ([0, 55, 0]) skadis_curved_hook(28, fullfill = true);
//translate ([0, 120, 0]) skadis_curved_hook(36, fullfill = true, retainer = true);

// Straight hooks demo
//translate([0, 0, 0])  skadis_straight_hook(30, fullfill = false);
//translate([30, 0, 0])  skadis_straight_hook(60, fullfill = false);
//translate([60, 0, 0])  skadis_straight_hook(90, fullfill = false);
//translate([100, 0, 0])  skadis_straight_hook(120, fullfill = false);

// O holders demo
//skadis_o_holder();
//translate([30, 0, 0]) skadis_o_holder(retainer = true);
//translate([60, 0, 0]) skadis_o_holder(fullfill = false, retainer = true);
//translate([30, -50, 0]) skadis_o_holder(70);

// U holders demo
//skadis_u_holder();
//translate([30, 0, 0]) skadis_u_holder(retainer = true);
//translate([60, 0, 0]) skadis_u_holder(fullfill = false, retainer = true);

// Pliers demo
//skadis_plier(filet = 0);
//translate([0, 65, 0]) skadis_plier(60, 35, fullfill = false);
//translate([0, 135, 0]) skadis_plier(90, 40, filet = 8);
//translate([0, 205, 0]) skadis_plier(90, 40, filet = 12  , all_pegs = true);

// Plates demo
//skadis_plate();
//translate([0, 80, 0]) skadis_plate(l = 90, w = 40);
//translate([0, 180, 0]) skadis_plate(l = 90, w = 60, all_pegs = true);
//translate([120, 0, 0]) {
//    skadis_round_plate();
//    translate([0, 80, 0]) skadis_round_plate(50);
//    translate([0, 200, 0]) skadis_round_plate(90, all_pegs = true);
//}

// Boxes demo
//skadis_box();
//translate([0, 80, 0]) skadis_box(l = 90, w = 40, h = 30);
//translate([0, 180, 0]) skadis_box(l = 90, w = 60, h = 40, filet = 12, all_pegs = true);
//translate([120, 0, 0]) {
//    skadis_round_box();
//    translate([0, 80, 0]) skadis_round_box(d = 50, h = 40);
//    translate([0, 200, 0]) skadis_round_box(d = 90, h = 45, all_pegs = true);
//}

// Racks demo
//skadis_rack(d = 20);
//translate([0, 55, 0]) skadis_rack(d = 24, all_pegs = true);
//translate([0, 110, 0]) skadis_rack(d1 = 20, d2 = 12, all_pegs = false);
//translate([0, 180, 0]) skadis_rack(d1 = 20, d2 = 12, n = 12, compact = true, all_pegs = false);

// bits serie demo
//skadis_bits_serie(all_pegs = true);
//translate([0, 70, 0]) skadis_bits_serie(compact = true);
//translate([0, 120, 0]) skadis_bits_serie(h = 32, d = 1.2, step = 1.2, tolerance2 = 3.2, n = 9, compact = false);
//translate([0, 170, 0]) skadis_bits_serie(h = 28, d = 2.3, step = 1.5, n = 8, facets = 6, angle = 30, bottom = false, compact = false, tolerance2 = 0.2);
//translate([0, 235, 0]) skadis_bits_serie(h = 18, d = 14.6, step = 2, n = 6, facets = 4, angle = 45);
