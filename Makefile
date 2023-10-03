make:
	ns main.tcl

clean:
	-rm *.q *.queue *.a *.pdf *.c

plot: temp.q temp.a temp.c
	./plots/queue.plot
	./plots/average_queue.plot
	./plots/cwnd.plot

cleanall: clean
	-rm *~