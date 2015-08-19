all: inspect

inspect: main.o
	g++ main.o -o ../bin/inspect

main.o: main.cpp
	g++ -c main.cpp

clean:
	rm -rf *o ../bin/inspect

