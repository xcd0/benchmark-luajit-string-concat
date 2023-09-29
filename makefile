SHELL := /bin/bash

all:
	@/bin/echo -e "luajit : `which luajit`\n"
	stdbuf -oL luajit run.lua | tee run.log

run:
	# stdbufやteeが使えない環境向け
	luajit run.lua > run.log

gcoff:
	luajit run_gc_off.lua
	make plot
gcoff2:
	luajit run_gc_off.lua 200 100000  output2.csv
	make plot2
plot:
	gnuplot -e "set datafile separator ','; set terminal svg size 1800,1200; set xlabel 'count'; set ylabel '秒'; stats 'output.csv' using 1 name 'A'; stats 'output.csv' using 2 name 'B'; set output 'output.svg'; plot 'output.csv' using 0:1 with lines linewidth 0.5 title 'string.format', A_mean with lines linewidth 0.5 title 'string.format average', 'output.csv' using 0:2 with lines linewidth 0.5 title '..', B_mean with lines linewidth 0.5 title '.. average'"
plot2:
	#gnuplot -e "set datafile separator ','; set terminal svg size 1800,1200; set xlabel 'count'; set ylabel '秒'; set xrange [0:1000]; set yrange [0.1:0.4]; stats 'output2.csv' using 1 name 'A'; stats 'output2.csv' using 2 name 'B'; set output 'output_2.svg'; plot 'output2.csv' using 0:1 with lines linewidth 0.5 title 'string.format', '+' using 1:(A_mean) with lines linewidth 0.5 title 'string.format average', 'output2.csv' using 0:2 with lines linewidth 0.5 title '..', '+' using 1:(B_mean) with lines linewidth 0.5 title '.. average'"
	cat output2.csv | head -n 200 > tmp.csv
	#gnuplot -e "set xrange [0:5000]; set yrange [0.1:0.4]; set datafile separator ','; set terminal svg size 1800,1200; set xlabel 'count'; set ylabel '秒'; stats 'tmp.csv' using 1 name 'A'; stats 'tmp.csv' using 2 name 'B'; set output 'output_2.svg'; plot 'tmp.csv' using 0:1 with lines linewidth 0.5 title 'string.format', '+' using 1:(A_mean) with lines linewidth 0.5 title 'string.format average', 'tmp.csv' using 0:2 with lines linewidth 0.5 title '..', '+' using 1:(B_mean) with lines linewidth 0.5 title '.. average'"
	gnuplot -e "set xrange [0:200]; set datafile separator ','; set terminal svg size 1800,1200; set xlabel 'count'; set ylabel '秒'; stats 'tmp.csv' using 1 name 'A'; stats 'tmp.csv' using 2 name 'B'; set output 'output_2.svg'; plot 'tmp.csv' using 0:1 with lines linewidth 0.5 title 'string.format', '+' using 1:(A_mean) with lines linewidth 0.5 title 'string.format average', 'tmp.csv' using 0:2 with lines linewidth 0.5 title '..', '+' using 1:(B_mean) with lines linewidth 0.5 title '.. average'"

