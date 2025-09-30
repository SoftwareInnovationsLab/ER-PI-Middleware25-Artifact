# MAKEFLAGS += --silent

datalog:
	g++ -o datalog Datalog/DatalogGen.cpp
	./datalog 6 > ils.dl
	souffle ils.dl
ils:
	g++ -o interleave Datalog/IlGen.cpp
	./interleave

all:	datalog ils

run:
	node ProxyInvocations.js

test:
	npm test

clean:
	@rm -rf datalog interleave ils.dl *.pid *.log *.csv *.sum *.rdb interleavings/