#!/bin/bash

# File parameters
readonly LANGUAGE="english" # Language for the output file names
readonly OUTPUT_DIR="output" # Directory to save generated files
readonly SCAD_FILE="time_out_card.scad" # OpenSCAD script file
readonly OPENSCAD="openscad" # Path to the OpenSCAD executable

# Iteration parameters
readonly PERIODS=("1" "2" "3" "E") # Periods: 1 to 3 and E for Extra Time
readonly TEAMS=("H" "A") # Teams: Home (H) and Away (A) 
readonly MODULES=("svg" "card" "card_text") # Modules: svg, stencil, card, card_text

# Time-Out card parameters
readonly WIDTH=150 # Card width in mm, standard value 150
readonly LENGTH=210 # Card length in mm, standard value 210
readonly FILLET=6 # Corner fillet radius in mm, standard value 6
readonly CHAR_SIZE=36 # Character size in points, standard value 36
readonly MARGIN=12 # Margin size in mm, standard value 12

# Ensure the output directory exists
ensure_output_dir() {
    local dir=$1
    mkdir -p "$dir" || { echo "Error: Could not create directory $dir" >&2; exit 1; }
}

# Generate the output file name
generate_filename() {
    local period=$1 team=$2 module=$3
    local ext="stl"
    [ "$module" == "svg" ] && ext="svg"
    echo "${OUTPUT_DIR}/${LANGUAGE}_${period}_${team}_${module}.${ext}"
}

# Generate a file using OpenSCAD
generate_file() {
    local period=$1 team=$2 module=$3
    local output_file
    output_file=$(generate_filename "$period" "$team" "$module")

    local params=("-o" "$output_file" \
                  "-D" "selector=\"$module\"" \
                  "-D" "char_period=\"$period\"" \
                  "-D" "char_team=\"$team\"" \
                  "-D" "width=$WIDTH" \
                  "-D" "length=$LENGTH" \
                  "-D" "fillet=$FILLET" \
                  "-D" "char_size=$CHAR_SIZE" \
                  "-D" "margin=$MARGIN" "$SCAD_FILE")

    [ "$module" != "svg" ] && params=("--export-format" "stl" "${params[@]}")

    if ! $OPENSCAD "${params[@]}"; then
        echo "Error generating file: $output_file" >&2
        return 1
    fi

    echo "Generated: $output_file"
}

# Process combinations of PERIODS, TEAMS, and MODULES
process_combinations() {
    ensure_output_dir "$OUTPUT_DIR"

    local period team module
    for period in "${PERIODS[@]}"; do
        for team in "${TEAMS[@]}"; do
            for module in "${MODULES[@]}"; do
                generate_file "$period" "$team" "$module" || exit 1
            done
        done
    done
}

# Main entry point
main() {
    process_combinations
    echo "All files have been generated successfully."
}

# Execute the script
main
