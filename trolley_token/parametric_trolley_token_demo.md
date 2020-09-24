# Parametric trolley token generator

The file [parametric_trolley_token.scad](parametric_trolley_token.scad) can be used as an [OpenSCAD](http://www.openscad.org/) library to generate trolley tokens of any currency. There are two models to choose from; one with a flat surface convenient to be printed on [fused filament printers](https://en.wikipedia.org/wiki/Fused_filament_fabrication#Fused_deposition_modeling) without the need of any support material and another model meant to be printed on a [SLA printers](https://en.wikipedia.org/wiki/Stereolithography).

## Usage

The module `trolley_token()` takes up to 7 parameters:

1. coin_1_thickness = [numerical]
2. coin_2_thickness = [numerical]
3. coin_1_diameter = [numerical]
4. coin_2_diameter = [numerical]
5. coin_1_string = [string]
6. coin_2_string = [string]
7. sla_printer = [boolean]

## Demo

```
translate([0, 15, 0])
    trolley_token(string1 = "$$", string2 = "€€");
translate([0, 45, 0])
    trolley_token(2.15, 2.35, 23.2, 27.4, "2Fr", "5Fr", true);
translate([0, -15, 0])
    trolley_token(2.14, 2.38, 22.25, 24.25, "0.2€", "0.5€", true);
translate([0, -45, 0])
    trolley_token(2.33, 2.38, 23.25, 24.25, "1€", "0.5€", false);
```

![Parametric trolley token generator preview](images/parametric_trolley_token_demo.png)

## Coins dimension table

| Currency | Value | Diameter | Thickness |
|----------+-------+----------+-----------|
| SEK      | 1 kr  | 19.5 mm  | 1.79 mm   |
| SEK      | 2 kr  | 22.5 mm  | 1.79 mm   |
| SEK      | 5 kr  | 23.75 mm | 1.95 mm   |
| SEK      | 10 kr | 20.5 mm  | 2.9 mm    |
| EUR      | 0.2 € | 22.25 mm | 2.14 mm   |
| EUR      | 0.5 € | 24.25 mm | 2.38 mm   |
| EUR      | 1 €   | 23.25 mm | 2.33 mm   |
| EUR      | 2 €   | 25.75 mm | 2.20 mm   |
| CHF      | 1 Fr  | 23.20 mm | 1.55 mm   |
| CHF      | 2 Fr  | 27.40 mm | 2.15 mm   |
| CHF      | 5 fr  | 31.45 mm | 2.35 mm   |
| GBP      | 1 £   | 23.43 mm | 2.8 mm    |
| GBP      | 2 £   | 28.4 mm  | 2.5 mm    |
| ...      | ...   | ...      | ...       |