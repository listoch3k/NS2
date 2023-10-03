#!/usr/bin/gnuplot -persist

set encoding utf8

set terminal pdfcairo font "Arial,9"

set output "queue.pdf"

set grid
set style line 2

set xlabel "t (sec)"
set ylabel "Packets"

plot "temp.q" using ($1):($2)/1000 with lines title "Queue size (packets)" lt -1

unset output