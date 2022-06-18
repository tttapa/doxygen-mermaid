#!/usr/bin/env bash
set -ex
cd "$(dirname "$0")"
repodir="$PWD"/..
cd "$repodir"

output_folder="${1:-/tmp}"
mkdir -p "$output_folder"

# Function that builds the doxygen documentation.
# usage:    run_doxygen <branch-name> <output-directory>
function run_doxygen {
    branch="$1"
    outdir="$2"
    htmldir="Doxygen"
    if [ "$branch" != "main" ]; then outdir="$outdir/$htmldir"; fi
    # Remove the old documentation
    rm -rf "$outdir/$htmldir"
    mkdir -p "$outdir/$htmldir"
    # Tweak some Doxyfile verion numbers and output paths
    cat <<- EOF > tmp-Doxyfile
	@INCLUDE = Doxyfile
	PROJECT_NUMBER = "$branch"
	OUTPUT_DIRECTORY = "$outdir"
	HTML_OUTPUT = "$htmldir"
	GENERATE_LATEX = NO
	EOF
    # Generate the documentation
    doxygen tmp-Doxyfile
    rm -f tmp-Doxyfile
}

# Generate the documentation for the current branch
curr_branch=$(git branch --show-current)
if [ -n "$curr_branch" ]; then
    run_doxygen "$curr_branch" "$output_folder"
fi
# Generate the documentation for the current tag
if curr_tag=$(git describe --tags --exact-match); then
    run_doxygen "$curr_tag" "$output_folder"
fi

echo "Done generating documentation"

# Get all tags and branches for generating the index with links to docs for
# specific branches and versions:
git fetch
git fetch --tags

README="$output_folder/README.md"
echo "Documentation for" \
     "[**$GITHUB_REPOSITORY**](https://github.com/$GITHUB_REPOSITORY)." \
> "$README"

# Always have a link to main, it's at the root of the docs folder
echo -e '\n### Main Branch\n' >> "$README"
echo "- **main**  " >> "$README"
echo "  [Doxygen](Doxygen/index.html)" >> "$README"

# Find all tags with documentation (version numbers)
echo -e '\n### Tags and Releases\n' >> "$README"
git tag -l --sort=-creatordate \
 | while read tag
do
    index="$output_folder/$tag/Doxygen/index.html"
    if [ -e "$index" ]; then
        echo "- **$tag**  " >> "$README"
        echo "  [Doxygen]($tag/Doxygen/index.html)" >> "$README"
    else
        echo "tag $tag has no documentation"
    fi
done

# Find other branches (not version numbers)
echo -e '\n### Other Branches\n' >> "$README"
git branch -r --sort=-committerdate | cut -d / -f 2 \
 | while read branch
do
    index="$output_folder/$branch/Doxygen/index.html"
    if [ -e "$index" ]; then
        echo "- **$branch**  " >> "$README"
        echo "  [Doxygen]($branch/Doxygen/index.html)" >> "$README"
    else
        echo "branch $branch has no documentation"
    fi
done

echo -e "\n***\n" >> "$README"
# echo "<sup>Updated on $(date)</sup>" >> "$README"
cat > "$output_folder/_config.yml" << EOF
include:
  - "_modules"
  - "_sources"
  - "_static"
  - "_images"
EOF
