#!/usr/bin/gnuplot -persist

set encoding utf8

set terminal pdfcairo font "Arial,9"

set output "cwnd.pdf"

set grid
set style line 2

set xlabel "t (sec)"
set ylabel "Packets"

plot "temp.c" using ($1):($2) with lines title "CWND size (packets)" lt -1

unset output