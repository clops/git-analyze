#!/bin/sh

prefilter_log() {
    while read i;
    do
        echo "$i"
    done | cut -d " " --complement -f2,3
}

gen_data() {
    git log --format="format:%ai author"
    echo
    git log --format="format:%ci commit"
}

merge() {
    local curdate=""
    local cur_author_cnt=0
    local cur_commit_cnt=0
    while read date type
    do
        if [[ "$date" != "$curdate" ]]
        then
            [[ -n "$curdate" ]] && echo "$curdate" "$cur_author_cnt" "$cur_commit_cnt"
            cur_author_cnt=0
            cur_commit_cnt=0
            curdate="$date"
        fi

        if [[ "$type" = "author" ]]
        then
            cur_author_cnt=$((cur_author_cnt + 1))
        fi

        if [[ "$type" = "commit" ]]
        then
            cur_commit_cnt=$((cur_commit_cnt + 1))
        fi

    done
    echo "$curdate" "$cur_author_cnt" "$cur_commit_cnt"
}

tmp_file=/tmp/$$-gnuplot
gen_data | prefilter_log | sort | merge > $tmp_file

gnuplot -e "
    set output 'commits-per-day.png';
    set term png truecolor giant;
    set timefmt '%Y-%m-%d';
    set xtics 7;
    set grid y;
    set boxwidth 1.0 relative;
    set style fill transparent solid 0.5 noborder;
    plot '$tmp_file' using 0:2 with boxes title 'authored',
         '' using 0:3 with boxes title 'committed';
"

