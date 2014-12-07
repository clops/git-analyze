#!/bin/bash

# Plot size of merges

sum() {
    local curadd=0
    local curdel=0
    while read add del file
    do
        curadd=$((curadd + add))
        curdel=$((curdel + del))
    done
    echo "$curadd" "$curdel"
}

tmp_file=/tmp/$$-gnuplot

git log --author-date-order --reverse --format=format:'%H' --merges | \
while read hash
do
    git show "$hash" --format=tformat: --numstat | \
    grep -ve "^\-" - | sum | \
    while read add del file
    do
        echo "$add $del"
    done
done > $tmp_file

gnuplot -e "
   set output 'merge-size.png';
   set term png truecolor giant;
   set grid y;
   set logscale y;
   set ylabel 'Lines';
   set xlabel 'Merge';
   set yrange [1:*];
   set xrange [0:*];
   set boxwidth 1.0 absolute;

   set style data histogram;
   set style histogram clustered gap 1;

   set style fill solid 1.0 noborder;
   plot '$tmp_file' using 1 lc rgb'green'   title 'Added',
        ''          using 2 lc rgb'red'     title 'Removed';
"
