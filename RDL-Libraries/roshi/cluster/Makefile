MAKEFLAGS += --silent

datalog:
	g++ -o datalog Datalog/DatalogGen.cpp
	./datalog 6 > ils.dl
	souffle ils.dl
ils:
	g++ -o interleave Datalog/IlGen.cpp
	./interleave

all:	datalog ils

clean:
	@rm -rf datalog interleave ils.dl *.csv *.sum *.rdb interleavings/