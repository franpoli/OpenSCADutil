# Repository Overview

This is an independent git repository where you'll find [OpenSCAD](http://www.openscad.org/) utilities.
Each directory contains a small project with examples or instructions if necessary.

If you are looking for the official OpenSCAD git repository, please visit
[https://github.com/openscad/openscad/](https://github.com/openscad/openscad/).

---

# utilities
## svg_to_scad.py

Description: A python script to convert simple SVG files into a list of coordinates

Updated: 2025-04-22T16:33:10+02:00

[Project Directory](./utilities/svg_to_scad)
# libraries
## parametric_trolley_token.scad

Description: Parametric trolley token generator

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/trolley_token)

## time_out_card.scad

Description: #+DESCRIPTION: 

Updated: 2024-12-21T16:41:28+01:00

[Project Directory](./libraries/time_out_cards)

## thumbdrive_housing.scad

Description: Generates customizable USB drive cases

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/thumb_drive_housing)

## pipe_locks_generator.scad

Description: generates customizable locking mechanisms for pipes and tubes

Updated: 2024-12-01T16:38:41+01:00

[Project Directory](./libraries/pipe_locks_generator)

## milka_s_radius_gauge.scad

Description: This is an OpenSCAD script to generate Milka's radius gauge with slight variations

Updated: 2025-02-08T18:53:32+01:00

[Project Directory](./libraries/milka_s_radius_gauge)

## magnetic_card_display_holder.scad

Description: Generates a customizable stand designed to hold cards securely using magnets.

Updated: 2024-12-15T09:00:21+01:00

[Project Directory](./libraries/magnetic_card_display_holder)

## knurled_knob.scad

Description: Knurled knobs generator for bolts and nuts

Updated: 2025-01-05T22:55:56+01:00

[Project Directory](./libraries/knurled_knob)

## kitaboshi.scad

Description: Barrel generator for the Kita-Boshi 2mm mechanical pencil

Updated: 2025-09-29T17:50:42+02:00

[Project Directory](./libraries/kitaboshi)

## ikea_skadis.scad

Description: Generates Ikea Skådis pegboard accessories

Updated: 2025-04-22T17:12:12+02:00

[Project Directory](./libraries/ikea_skadis_pegboard_accessories)

## hakko_fx_888_sponge_template.scad

Description: Hakko soldering sponge template

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/hakko_fx_888_soldering_sponge_template)

## hakko_fx_888d_magnetic_tips_holder.scad

Description: Hakko FX-888D Magnetic Tips Holder

Updated: 2024-12-15T07:11:38+01:00

[Project Directory](./libraries/hakko_fx_888d_magnetic_tips_holder)

## grinder_handel.scad

Description: generates a grinder handel

Updated: 2025-08-19T18:16:13+02:00

[Project Directory](./libraries/grinder_handle)

## floor_drain_filter.scad

Description: Generates floor drain filters

Updated: 2025-09-11T06:06:37+02:00

[Project Directory](./libraries/floor_drain_filter)

## extra.scad

Description: OpenSCAD Reusable Modules and Function Library

Updated: 2025-05-04T20:01:19+02:00

[Project Directory](./libraries/extra)

## escutcheon.scad

Description: Parametric escutcheon generator

Updated: 2024-06-08T16:05:52+02:00

[Project Directory](./libraries/escutcheon)

## cabletie.scad

Description: Generates simple, quick and easy to print TPU cable ties

Updated: 2024-06-09T23:37:30+02:00

[Project Directory](./libraries/cabletie)

## Apple AirTag Accessories

Description: OpenSCAD modules for designing Apple AirTag-compatible accessories

Updated: 2025-05-04T20:01:19+02:00

[Project Directory](./libraries/apple_airtag_accessories)

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
chmod u+x .git/hooks/pre-commit
```


