#!/bin/bash

# Define variables
LANGUAGE="english"
OUTPUT_DIR="output"
SCAD_FILE="time_out_card.scad"
OPENSCAD="openscad"

PERIODS="1 2 3 E" # Where E stands for Extra Time
TEAMS="H A"
MODULES="svg card card_text"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through each period, team, and module combination
for period in $PERIODS; do
    for team in $TEAMS; do
        for module in $MODULES; do
            # Output file name based on period, team, and module
            output_file="${OUTPUT_DIR}/${LANGUAGE}_${period}_${team}_${module}.${module}"

            if [ "$module" == "svg" ]; then
                # Generate SVG files using the "svg" modulle
                $OPENSCAD -o "$output_file" -D "selector=\"$module\"" -D "char_period=\"$period\"" -D "char_team=\"$team\"" "$SCAD_FILE"
            else
                # Generate STL files using the either the "card" and "card_text" modules)
                output_file="${OUTPUT_DIR}/${LANGUAGE}_${period}_${team}_${module}.stl"
                $OPENSCAD -o "$output_file" --export-format stl -D "selector=\"$module\"" -D "char_period=\"$period\"" -D "char_team=\"$team\"" "$SCAD_FILE"
            fi

            # Check if the previous command failed
            if [ $? -ne 0 ]; then
                echo "Error generating file: $output_file"
                exit 1  # Exit the script on error
            fi
        done
    done
done

# Echo if no errors occurred
echo "All files have been generated."
