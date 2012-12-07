
all: display

wifistates.bmp: wifistates.dot graph.py
	dot wifistates.dot -Tbmp -owifistates.bmp

display: wifistates.bmp
	open -a Preview wifistates.bmp

parse: graph.py wifistates.bmp
	#./graph.py wifistates.dot xx
	./graph.py wifistates.dot
	g++ testprog.cc

graph.py: graph.g
	python ../yapps/yapps2.py graph.g 
	chmod a+x graph.py
