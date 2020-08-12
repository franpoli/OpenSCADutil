# Parametric trolley token generator

This can be used as an OpenSCAD library to generate trolley tokens for any currency.

## Usage:

```
// Coins dimension variables
// c1t="5kr";		[coin 1 text], enter "" for no value
// c1d=23.75;		[coin 1 diameter]
// c1h=1.95;		[coin 1 heigth (thickness)]
// c2t="10kr";		[coin 2 text], enter "" for no value
// c2d=20.5;		[coin 2 diameter]
// c2h=2.9; 		[coin 2 heigth (thickness)]

// module calls demo
translate([0, 15, 0])
    trolley_token(c1h, c2h, c1d, c2d, c1t, c2t);
translate([0, 45, 0])
    trolley_token(c1h, c2h, c1d, c2d, c1t, c2t, fdm);
translate([0, -15, 0])
    trolley_token(2.14, 2.38, 22.25, 24.25, "0.2€", "0.5€", fdm);
translate([0, -45, 0])
    trolley_token(2.33, 2.38, 23.25, 24.25, "1€", "0.5€", sla);
```

## Preview:

![Parametric trolley token generator preview](parametric_trolley_token_demo.png)