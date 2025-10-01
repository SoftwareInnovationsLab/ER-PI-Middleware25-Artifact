# MAKEFLAGS += --silent

init:
	go build -o Library/ Library/ast_rewrite.go
	Library/ast_rewrite < Library/pncounter.go > Library/pncounter_proxy.go
	Library/ast_rewrite < Library/server.go > Library/server_proxy.go

datalog:
	g++ -o datalog Datalog/DatalogGen.cpp
	./datalog 6 > ils.dl
	souffle ils.dl
ils:
	g++ -o interleave Datalog/IlGen.cpp
	
crdt:
	go mod download github.com/go-redis/redis
	go build Library/server_proxy.go Library/client.go Library/pncounter_proxy.go Library/file_reader.go Library/IL_Helper.go Library/wrapper.go

all:	init datalog ils crdt 
		sleep 20 
		./interleave

clean:
	@rm -rf server_proxy datalog interleave ils.dl *.csv 
	@rm -rf Library/Actions.txt *.sum *.rdb interleavings/ 
	@rm -rf Library/pncounter_proxy.go Library/ast_rewrite Library/server_proxy.go
	@rm -rf InitRun/ *.log *.pid *.rdb