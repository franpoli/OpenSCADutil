# Repository Overview

This is an independent git repository where you'll find [OpenSCAD](http://www.openscad.org/) utilities.
Each directory contains a small project with examples or instructions if necessary.

If you are looking for the official OpenSCAD git repository, please visit
[https://github.com/openscad/openscad/](https://github.com/openscad/openscad/).

---

# utilities
## svg_to_scad.py

Description: A python script to convert simple SVG files into a list of coordinates

Updated: 2024-06-08T16:16:51+02:00

[Project Directory](./utilities/svg_to_scad)
# libraries
## cabletie.scad

Description: Generates simple, quick and easy to print TPU cable ties

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/cabletie)

## escutcheon.scad

Description: Parametric escutcheon generator

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/escutcheon)

## hakko_fx_888_sponge_template.scad

Description: Hakko soldering sponge template

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/hakko_fx_888_soldering_sponge_template)

## ikea_skadis.scad

Description: Generates Ikea Skådis pegboard accessories

Updated: 2024-06-08T14:57:47+02:00

[Project Directory](./libraries/ikea_skadis_pegboard_accessories)

## kitaboshi_demo.scad

Description: Barrel generator for the Kita-Boshi 2mm mechanical pencil

Updated: 2024-06-08T16:10:29+02:00

[Project Directory](./libraries/kitaboshi)

## knurled_knob.scad

Description: Knurled knobs generator for bolts and nuts

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/knurled_knob)

## milka_s_radius_gauge.scad

Description: This is an OpenSCAD script to generate Milka's radius gauge with slight variations

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/milka_s_radius_gauge)

## thumbdrive_housing.scad

Description: Generates customizable USB drive cases

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/thumb_drive_housing)

## parametric_trolley_token.scad

Description: Parametric trolley token generator

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/trolley_token)

---

## Updating README.md

To update the README.md file with the latest information from the README.org files in the
repository, run the following command in the root directory of the repository:

```bash
bash update_readme.sh
```

This will generate a new README.md file with the updated information.

Alternatively, you can copy the `update_readme.sh` script to your git hooks directory to
automatically update the README.md file every time you commit changes. To do this, run the
following commands:

```bash
cp update_readme.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```


