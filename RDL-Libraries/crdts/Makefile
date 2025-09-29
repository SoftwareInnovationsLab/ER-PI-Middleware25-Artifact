build:
	gradle build

datalog:
	g++ -o datalog Datalog/DatalogGen.cpp
	./datalog 18 > ils.dl
	souffle ils.dl

ils:
	g++ -o interleave Datalog/IlGen.cpp

test:
	gradle test

all:	datalog ils build
	@echo "gradle run is starting..."
	@gradle run &
	@echo "Waiting for 30 seconds before executing ./interleave..."
	@sleep 30 && ./interleave &
clean:
	gradle clean
	@rm -rf datalog interleave ils.dl *.csv
	@rm -rf interleavings/
	@rm -rf Events/
