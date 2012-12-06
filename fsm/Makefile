
all: display

foo.bmp: test.dot graph.py
	dot test.dot -Tbmp -ofoo.bmp

display: foo.bmp
	open -a Preview foo.bmp

parse: graph.py
	#./graph.py test.dot xx
	./graph.py test.dot

graph.py: graph.g
	python ../yapps/yapps2.py graph.g 
	chmod a+x graph.py
