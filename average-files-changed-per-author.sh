#!/bin/bash

tmp_file=/tmp/$$-gnuplot
git log --format='%aN' | sort -u | while read author
do
    av=$(git log --author="$author" --pretty=tformat: --shortstat | \
            cut -d " " -f 2 | \
            awk '{ t += $1; c++ } END { print t/c }')

    echo "$av $author"
done >> $tmp_file

gnuplot -e "
    reset;
    set output 'commits-per-author.png';
    set term png truecolor;
    set ylabel 'Files per Commit';
    set xlabel 'Committer';
    set yrange [0:5];
    set grid y;
    set boxwidth 0.95 relative;
    set style fill transparent solid 0.5 noborder;
    plot '$tmp_file' using 1:xtic(2) with boxes lc rgb'green' notitle;
"

rm $tmp_file
