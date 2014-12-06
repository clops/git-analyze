#!/bin/sh

if [[ -z "$1" ]];
then
    echo "No additional git flags..."

    cat <<EOS
    You can do:

        --grep=<pattern> to search for a pattern in the commit messages
        --all-match to match against all --grep patterns
        --author=<author> to limit to one author, multiple possible
        --committer=<committer> to limit to one committer, multiple possible

EOS
    exit 1
fi

ADDITIONALS=$*

prefilter_log() {
    while read i;
    do
        echo "$i"
    done | cut -d " " --complement -f2,3
}

gen_data() {
    git log $ADDITIONALS --format="format:%ai author"
    echo
    git log $ADDITIONALS --format="format:%ci commit"
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

min_date=$(cat $tmp_file | head -n 1 | cut -d " " -f 1)
max_date=$(cat $tmp_file | tail -n 1 | cut -d " " -f 1)

echo $min_date
echo $max_date

gnuplot -e "
    set output 'commits-per-day-with.png';
    set term png truecolor giant;
    set xdata time;
    set timefmt '%Y-%m-%d';
    set format x '%Y-%m-%d';
    set grid y;
    set boxwidth 1.0 relative;
    set style fill transparent solid 0.5 noborder;
    plot '$tmp_file' using 1:2 with boxes title 'authored',
         '' using 1:3 with boxes title 'committed';
"


