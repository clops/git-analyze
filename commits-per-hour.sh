#!/bin/bash

# number of commits grouped by hour
# (author time)

git log --format=format:'%ai' --all | \
cut -d " " -f 2 | \
cut -d ":" -f 1 | \
sort | \
uniq -c | \
gnuplot -e "
    set output 'commits-per-hour.png';
    set term png truecolor giant;
    set ylabel 'Commits';
    set grid y;
    set boxwidth 0.9 relative;
    set style fill transparent solid 1.0 noborder;
    plot '-' using 1:xtic(2) with boxes lc rgb'green' notitle;
"
