#!/bin/env bash

# Constant variables
OUTPUT_FILE="README.md"
PROJECTS_DIR="."

# Function to extract the title, description, and last updated date from a README.org file
extract_info() {
    local file="$1"

    # Use awk to extract the title, description, and last updated date from the README.org file
    local title=$(awk '/^#\+TITLE:/{print substr($0, index($0, $2))}' "$file")
    local description=$(awk '/^#\+DESCRIPTION:/{print substr($0, index($0, $2))}' "$file")

    # Get the directory containing the README.org file
    local dir=$(dirname "$file")

    # Find the last updated file within the project directory
    local updated=$(find "$dir" -type f -exec stat -c "%Y %n" {} + | sort -nr | head -n 1 | cut -d' ' -f1)
    updated=$(date -d @"$updated" --iso-8601=seconds)

    echo "$title|$description|$updated|$dir"
}

# Function to generate the table of contents for a category with project sorting
generate_toc_sorted() {
    local project_dir="$1"
    local toc=""

    # Find all README.org files within the category
    local readme_files=($(find "$project_dir" -name "README.org" | sort -nr)) 

    for readme_file in "${readme_files[@]}"; do
        local info=$(extract_info "$readme_file")
        IFS='|' read -r title description updated dir <<< "$info"
        
        if [[ -n "$title" && -n "$description" ]]; then
            toc+="## $title\n\n"
            toc+="Description: $description\n\n"
            toc+="Updated: $updated\n\n"
            toc+="[Project Directory]($dir)\n\n"
        fi
    done

    echo -e "$toc"
}

# Write the content directly to README.md
cat > "$OUTPUT_FILE" <<EOL
# Repository Overview

This is an independent git repository where you'll find [OpenSCAD](http://www.openscad.org/) utilities.
Each directory contains a small project with examples or instructions if necessary.

If you are looking for the official OpenSCAD git repository, please visit
[https://github.com/openscad/openscad/](https://github.com/openscad/openscad/).

---

EOL

# Generate the table of contents with sorted projects for each category
for category in $(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d); do
    category_name=$(basename "$category")
    # Skip unwanted directories
    if [[ "$category_name" == ".git" || "$category_name" == "node_modules" || "$category_name" == "other_unwanted_dir" ]]; then
        continue
    fi

    echo "# $category_name" >> "$OUTPUT_FILE"
    toc=$(generate_toc_sorted "$category")
    echo -e "$toc" >> "$OUTPUT_FILE"
done

# Add instructions on how to use update_readme.sh
cat >> "$OUTPUT_FILE" <<EOL

---

## Updating README.md

To update the README.md file with the latest information from the README.org files in the
repository, run the following command in the root directory of the repository:

\`\`\`bash
bash update_readme.sh
\`\`\`

This will generate a new README.md file with the updated information.

Alternatively, you can copy the \`update_readme.sh\` script to your git hooks directory to
automatically update the README.md file every time you commit changes. To do this, run the
following commands:

\`\`\`bash
cp update_readme.sh .git/hooks/pre-commit
chmod u+x .git/hooks/pre-commit
\`\`\`


EOL

# Check if the README.md file has changed
if ! git diff --quiet "$OUTPUT_FILE"; then
    echo "README.md file has been updated."
    # Optionally stage the README.md file for commit
    git add "$OUTPUT_FILE"
else
    echo "No changes to README.md file detected."
fi

# Graceful degradation
trap 'echo "Hook failed. Commit will proceed without updating README.md."; exit 0' ERR
