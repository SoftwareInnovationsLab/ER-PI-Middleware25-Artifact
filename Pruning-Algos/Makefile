group:
	g++ -o event_group event_group.cpp
	./event_group

replica:
	g++ -o replica_specific replica_specific.cpp
	echo 1 | ./replica_specific

independence:
	g++ -o event_independence event_independence.cpp
	./event_independence

failed:
	g++ -o failed_ops failed_ops.cpp
	./failed_ops

clean:
	@rm -rf event_group replica_specific event_independence failed_ops GI.dl RI.dl independent_interleavings.dl