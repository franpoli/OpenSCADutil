# cable ties generator

The file cabletie.scad can be used as an OpenSCAD library to generate cable ties of different sizes.

Tighten, these printed cable tie hold by themself. They can be released by a small hand pressure.

## Usage

The module `cabletie()` takes up to 5 parameters:

1. cabletie_width (w) = [numerical];
2. cabletie_wrapping_diameter (d) = [numerical];
3. cabletie_minimum_thickness (t) = [numerical]; // would be override if to large
4. nozzle_width (nw) = [numerical];
5. printer_tolerance (pt) = [numerical];

## Demo

```scad
cabletie(6, 15, 1.0);
translate([0, -12, 0]) cabletie(6, 20, 1.0);
translate([0, -24, 0]) cabletie(w=6, d=25, t=1.0);

translate([0, -40, 0]) cabletie(8, 20, 1.2);
translate([0, -55, 0]) cabletie(8, 25, 1.2);
translate([0, -70, 0]) cabletie(w=8, d=30, t=1.2);

translate([0, -90, 0]) cabletie(10, 35, 1.4);
translate([0, -108, 0]) cabletie(10, 45, 1.4);
translate([0, -126, 0]) cabletie(w=10, d=55, t=1.4);
```

![Cable ties generator demo](images/cabletie_demo.png)

## Customizer

You may also use the OpenSCAD customizer utility to conveniently chenge the parameters:

![Cable tie customizer](images/cabletie_customizer.png)


