#!/bin/bash

# Marius Montebaur, 20.06.2020
# Cameron Brooks, 12.06.2025
# Converts all markdown files given as args to html with a given template.
# Is called once and gets all markdown files as command line args.
#
# example arg:
# $ ./convert.sh source/*.md
#
# example usage:
# $ ./convert.sh source/*.md  # markdown files have to be inside source folder
# $ ./convert.sh  # will look for .md files in the source folder
#

website_dir=_website  # output of the translated website
source_dir=source  # folder containing the source files, i.e. markdown files

# ------------------------------------------------------------
# enable alias expansion in non-interactive shell
# ------------------------------------------------------------
# jeez, why isn't that enabled by default:
# http://chiefsandendians.blogspot.com/2010/07/linux-scripts-and-alias.html
shopt -s expand_aliases


# ------------------------------------------------------------
# Detect platform and set in-place sed (“sedi”) accordingly
# - Linux/Git-Bash (MINGW/MSYS) use GNU sed syntax:    sed -i
# - macOS/BSD use BSD sed syntax:                      sed -i ''
# ------------------------------------------------------------
# Original thanks to https://stackoverflow.com/a/6836122
case "$(uname -s)" in
    Linux*|MINGW*|MSYS*)
        alias sedi="sed -i"
    ;;
    Darwin*|FreeBSD*|OpenBSD*)
        alias sedi="sed -i ''"
    ;;
    *)
        alias sedi="sed -i"
    ;;
esac

# ------------------------------------------------------------
# Create command for relative path (realpath alternative)
# ------------------------------------------------------------
relpath() {
    python3 -c "import os.path; print(os.path.relpath('$1','$2'))" ;
}

# ------------------------------------------------------------
# Prefer a local pandoc if present
# ------------------------------------------------------------
# e.g. Uberspace only has an outdated version
if [ -f ~/bin/pandoc ]; then
    alias pandoc="~/bin/pandoc"
    echo "Switched to local pandoc"
fi

echo "Using pandoc version:" `pandoc -v | head -n 1`

# ------------------------------------------------------------
# (Re)create output directory
# ------------------------------------------------------------
rm -rf $website_dir
mkdir $website_dir

# ------------------------------------------------------------
# Gather markdown files (from args or by scanning source_dir)
# ------------------------------------------------------------
if [ $# -eq 0 ]; then
    # find markdown files if none are given
    md_files=`find $source_dir -name "*.md"`
else
    md_files=$@
fi

# ------------------------------------------------------------
# Main conversion loop
# ------------------------------------------------------------
for template in $md_files;
do
    filename="$(basename "$template" .md).html"  # e.g. source/projects/file.md -> file.html
    filepath=`dirname "${template#*/}"`          # e.g. source/projects/file.md -> projects
    
    mkdir -p $website_dir/$filepath              # create output directory like _website/projects
    
    out_file=$website_dir/$filepath/$filename    # full output path e.g. _website/projects/file.html
    
    
    # calculate how deep this file is to find relative path to root
    # used to find stylesheet and such in website's root
    dir_depth=`relpath '.' $filepath`
    
    stylesheet_path=$dir_depth/styling.css
    
    # --columns 10000 is ugly but without it html tables are broken: https://github.com/jgm/pandoc/issues/2574
    
    # Variables are passed through to the template and can be used there.
    # rel_path: used to navigate to the website's root. e.g. "../"
    # root_path: used to list page's url in open graph protocol. https://ogp.me/
    # current_date: is appended as a querying parameter to the css file to refresh the cache after the website updated
    
    pandoc $template \
    --mathml \
    --from=markdown \
    --to=html \
    --template template.html \
    --columns 10000 \
    --number-sections \
    --css $stylesheet_path \
    --toc --toc-depth=2 \
    --metadata autor="Marius Montebaur" \
    --variable=rel_path:"$dir_depth/" \
    --variable=document_path:"$filepath/$filename" \
    --variable=current_date:"$(date +%Y-%m-%d_%H-%M-%S)" \
    --citeproc \
    --output=$out_file
    
    # remove two leading spaces from code blocks
    sedi "/  <span id=\"cb/s/^  //g" $out_file
    
    echo "converted $template -> $out_file"
done

# copy static assets
cp styling.css $website_dir/
cp -r source/media $website_dir/

# remove all hidden files except .htaccess
find $website_dir/ -type f -name '.*' ! -name ".htaccess" -delete

echo "conversion done."
