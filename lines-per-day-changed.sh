#!/bin/bash

sum() {
    curdate=""
    cur_add=0
    cur_del=0
    while read add del date
    do
        if [[ "$date" != "$curdate" ]]
        then
            [[ -n "$curdate" ]] && echo "$cur_add" "$cur_del" "$curdate"
            cur_add=0
            cur_del=0
            curdate="$date"
        fi

        cur_add=$((cur_add + add))
        cur_del=$((cur_del + del))

    done
    echo "$curdate" "$cur_add" "$cur_del"
}

tmp_file=/tmp/$$-gnuplot

git log --all --format=format:'%H %ci' | while read hash cdate
do
    git show "$hash" --format=tformat: --numstat | \
        awk 'NF==3 {add+=$1; del+=$2} END {printf("%d %d\n", add, del)}' |\
    while read add del file
    do
        echo "$add $del $cdate"
    done
done | \
cut -d " " -f 1-3 | \
sed 's/^\-\ \-/0\ 0/' | \
sort -k3.4 -k3.7 -k3.9 | \
sum > $tmp_file

gnuplot -e "
    reset;
    set output 'lines-per-day-changed.png';
    set term png truecolor;
    set ylabel 'Changes';
    set xlabel 'Day';
    set yrange [0:*];
    set xrange [0:*];
    set grid y;
    set boxwidth 0.95 relative;

    set style data histogram;
    set style histogram clustered gap 1;

    set style fill solid 1.0 noborder;
    plot '$tmp_file' using 1 lc rgb'green' title 'Added',
         ''          using 2 lc rgb'red'   title 'Deleted';
"

