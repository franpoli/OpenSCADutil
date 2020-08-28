# Parametric Ikea Skådis Pegboard Accessories

The file `ikea_skadis.scad` can be used as an OpenSCAD library to generate accessories for the [IKEA Skådis pegboard](https://duckduckgo.com/?q=%22IKEA+Sk%C3%A5dis+pegboard%22&t=hk&ia=web).

## Usage:

```
// Curved hooks demo
skadis_curved_hook(fullfill = false);
translate ([30, 0, 0]) skadis_curved_hook(fullfill = false);
translate ([60, 0, 0]) skadis_curved_hook(fullfill = false, retainer = true);
translate ([0, 55, 0]) skadis_curved_hook(28, fullfill = true);
translate ([0, 120, 0]) skadis_curved_hook(36, fullfill = true, retainer = true);
```

![Ikea Skådis curved hooks](images/IkeaSkadisCurvedHooksDemo.png)

```
// Straight hooks demo
translate([0, 0, 0])  skadis_straight_hook(30, fullfill = false);
translate([30, 0, 0])  skadis_straight_hook(60, fullfill = false);
translate([60, 0, 0])  skadis_straight_hook(90, fullfill = false);
translate([100, 0, 0])  skadis_straight_hook(120, fullfill = false);
```

![Ikea Skådis straight hooks](images/IkeaSkadisStraightHooksDemo.png)

```
// O holders demo
skadis_o_holder();
translate([30, 0, 0]) skadis_o_holder(retainer = true);
translate([60, 0, 0]) skadis_o_holder(fullfill = false, retainer = true);
translate([30, -50, 0]) skadis_o_holder(70);
```

![Ikea Skådis O holders](images/IkeaSkadisOHoldersDemo.png)

```
// U holders demo
skadis_u_holder();
translate([30, 0, 0]) skadis_u_holder(retainer = true);
translate([60, 0, 0]) skadis_u_holder(fullfill = false, retainer = true);
```

![Ikea Skådis U holders](images/IkeaSkadisUHoldersDemo.png)

```
// Pliers demo
skadis_plier();
translate([0, 65, 0]) skadis_plier(60, 35, fullfill = false);
translate([0, 135, 0]) skadis_plier(90, 40, filet = 8);
translate([0, 205, 0]) skadis_plier(90, 40, filet = 12, all_pegs = true);
```

![Ikea Skådis plier Demo](images/IkeaSkadisPliersDemo.png)

```
// Plates demo
skadis_plate();
translate([0, 80, 0]) skadis_plate(l = 90, w = 40);
translate([0, 180, 0]) skadis_plate(l = 90, w = 60, all_pegs = true);
translate([120, 0, 0]) {
    skadis_round_plate();
    translate([0, 80, 0]) skadis_round_plate(50);
    translate([0, 200, 0]) skadis_round_plate(90, all_pegs = true);
}
```

![Ikea Skådis plates Demo](images/IkeaSkadisPlatesDemo.png)

```
// Boxes demo
skadis_box();
translate([0, 80, 0]) skadis_box(l = 90, w = 40, h = 30);
translate([0, 180, 0]) skadis_box(l = 90, w = 60, h = 40, filet = 12, all_pegs = true);
translate([120, 0, 0]) {
    skadis_round_box();
    translate([0, 80, 0]) skadis_round_box(d = 50, h = 40);
    translate([0, 200, 0]) skadis_round_box(d = 90, h = 45, all_pegs = true);
}
```

![Ikea Skådis boxes Demo](images/IkeaSkadisBoxesDemo.png)

```
// Racks demo
skadis_rack(d = 20);
translate([0, 55, 0]) skadis_rack(d = 24, all_pegs = true);
translate([0, 110, 0]) skadis_rack(d1 = 20, d2 = 12, all_pegs = false);
translate([0, 180, 0]) skadis_rack(d1 = 20, d2 = 12, n = 12, compact = true, all_pegs = false);
```

![Ikea Skådis racks Demo](images/IkeaSkadisRacksDemo.png)

```
// bits serie demo
skadis_bits_serie(all_pegs = true);
translate([0, 70, 0]) skadis_bits_serie(compact = true);
translate([0, 120, 0]) skadis_bits_serie(h = 32, d = 1, step = 1, tolerance2 = 3.2, n = 9, compact = false);
translate([0, 170, 0]) skadis_bits_serie(h = 28, d = 2, step = 1, n = 7, facets = 6, angle = 30, bottom = false, compact = false);
translate([0, 235, 0]) skadis_bits_serie(h = 18, d = 10, step = 2, n = 6, facets = 4, angle = 45);
```

![Ikea Skådis bits serie](images/IkeaSkadisBitsSerie.png)

## Pictures of some 3D printed accessories

![Office Skådis pegboard](images/photographs_ikea_skadis_pegboard_accessories_001.jpg "Office")

![Workshop Skådis pegboard](images/photographs_ikea_skadis_pegboard_accessories_002.jpg "Workshop")

![Garage Skådis pegboard](images/photographs_ikea_skadis_pegboard_accessories_003.jpg "Garage")