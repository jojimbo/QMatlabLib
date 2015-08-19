files=$(find . -type f -iname \*.m -print0 | xargs -0 grep addpath)

echo "Found the following files with addpath directives. Removing offending lines now..."

for file in $files; do
	echo "$file"
	sed -i -e "s/.*addpath.*//" "$file"
done 
