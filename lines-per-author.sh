#!/bin/bash

git log --format='%aN' | sort -u | while read author
do
    git log --author="$author" --numstat --pretty='%H' --all |\
        awk 'NF==3 {add+=$1; del+=$2} END {printf("%d %d\n", add, del)}' |\
        while read add del
        do
            echo "$add $del $author"
        done
done > /tmp/test.gnuplot

gnuplot -e "
    reset;
    set output 'lines-per-author.png';
    set term png truecolor;
    set ylabel 'Lines';
    set xlabel 'Author';
    set grid y;
    set auto x;
    set yrange [0:*];
    set boxwidth 0.9 absolute;

    set style data histogram;
    set style histogram clustered gap 1;

    set style fill solid 1.0 noborder;
    plot '/tmp/test.gnuplot' using 1:xtic(3) lc rgb'green' title 'Added',\
         ''                  using 2:xtic(3) lc rgb'red' title 'Removed';
"
