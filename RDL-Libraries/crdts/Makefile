# Build Java project
build:
	gradle build

# Generate datalog
datalog:
	g++ -o datalog Datalog/DatalogGen.cpp
	./datalog 6 > ils.dl
	souffle ils.dl

# Compile interleave generator
ils:
	g++ -o interleave Datalog/IlGen.cpp

# Run tests
test:
	gradle test

# All: generate interleavings first, then Gradle run
all:	datalog ils
	@echo "Generating interleavings..."
	@./interleave
	@echo "Gradle build and run will be handled by crdts_run.sh"

# Clean
clean:
	gradle clean
	@rm -rf datalog interleave ils.dl *.csv *.log *.pid
	@rm -rf interleavings/
	@rm -rf Events/
