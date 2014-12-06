#!/bin/sh

tmp_file=/tmp/$$-gnuplot
git shortlog -s -n --all > $tmp_file

gnuplot -e "
    reset;
    set output 'commits-per-author.png';
    set term png truecolor;
    set ylabel 'Commits';
    set xlabel 'Committer';
    set grid y;
    set boxwidth 0.95 relative;
    set style fill transparent solid 0.5 noborder;
    plot '$tmp_file' using 1:xtic(2) with boxes lc rgb'green' notitle;
"
