
all:
	dot ION_architecture.dot -Tbmp -ofoo

display:
	open -a Preview foo.bmp

parse: graph.py
	./graph.py test.dot xx

graph.py: graph.g
	python ../yapps/yapps2.py graph.g 
	chmod a+x graph.py
