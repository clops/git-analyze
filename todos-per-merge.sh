#!/bin/bash

OLD_HEAD=$(git log HEAD -n 1 --format=format:%H)
todostr="@todo"

tmpfile=/tmp/$$-gnuplot

for merge in $(git log --merges --format=format:"%H" --reverse)
do
    git checkout "$merge" >/dev/null
    dat=$(git log --format=format:"%ci" HEAD -n 1 | sed 's/\ +[0-9]*//' | \
            sed 's/\ /T/')
    nto=$(git grep $todostr | wc -l)

    echo "'$dat' $nto"
done > $tmpfile

gnuplot -e "
set output 'todos-per-merge.png';
set term png truecolor giant;
set xdata time;
set timefmt  \"'%Y-%m-%dT%H:%M:%S'\";
set xtics 2419200;
set format x \"'%Y-%m-%d'\";
plot '$tmpfile' using 1:2 with lines notitle;
"

git checkout $OLD_HEAD
