package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/go-redis/redis"
)

// Application constants, defining host, port, and protocol.
const (
	//connHost = "localhost"
	//connPort = "8080"
	connType = "tcp"
)

var hosts []string
var counter *Counter

var conns []net.Conn

// Redis Distributed Locking Mechanism
func acquireLock(client *redis.Client, key string, expiration time.Duration) (bool, error) {
	// Use the SET command to try to acquire the lock
	result, err := client.SetNX(key, "lock", expiration).Result()
	if err != nil {
		return false, err
	}
	return result, nil
}

func releaseLock(client *redis.Client, key string) error {
	// Use the DEL command to release the lock
	_, err := client.Del(key).Result()
	return err
}

func TestFinalValue(t *testing.T, result int) {
	expected := 2
	if result != expected {
		t.Errorf("EndResult is %d, expected %d", result, expected)
		fmt.Println("FAIL")
	} else {
		t.Log("PASS")
		fmt.Println("PASS")
	}
}
func do_actions(actions []string, mutexKey string, attributeKey string, client *redis.Client) {

	//sleep for 5 secs, so other replicase
	//have time to get started
	time.Sleep(5 * time.Second)

	// measuring time required to execute a single interleaving
	// start := time.Now()

	fmt.Println("Starting to do_actions")
	for _, action := range actions {
		opt_info := strings.Split(action, "_")
		opt := opt_info[0]
		replica_id, _ := strconv.Atoi(opt_info[1])
		lamport_t, _ := strconv.Atoi(opt_info[2])
		// fmt.Println("opt: ", opt)
		// fmt.Println("replica_id: ", replica_id)
		// fmt.Println("lamport_t: ", lamport_t)

		if replica_id == counter.id {
			var currentValue string
			var lockTime int
			for {
				currentValue, _ = client.Get(attributeKey).Result()
				lockTime, _ = strconv.Atoi(currentValue)
				if lockTime == lamport_t {
					break
				}
			}

			Lock, err := acquireLock(client, mutexKey, time.Second*5)
			if err != nil {
				fmt.Println("Error acquiring lock:", err)
				// return
				continue
			}
			if !Lock {
				fmt.Println("Failed to acquire lock")
				// return
				continue
			}

			// Do some work while holding the lock
			fmt.Println("Lock successfully acquired!")

			if opt == "Inc" {
				counter.Inc()
				fmt.Println(counter.Print())
			} else if opt == "Dec" {
				counter.Dec()
				fmt.Println(counter.Print())
			} else if opt == "Broadcast" {
				fmt.Println("processing Broadcast")
				if conns == nil { //establish connecitons on first broadcast
					conns = establishConnections(hosts)
				}
				//conns = establishConnections(hosts)
				fmt.Println("About to broadcast Counter" + counter.Print())
				broadcast(conns, counter.ToMarshal())
			} else { //assume it is delay
				var err error
				var number int
				if number, err = strconv.Atoi(action); err != nil {
					panic(err)
				}
				time.Sleep(time.Duration(number) * time.Second)
			}
			err = releaseLock(client, mutexKey)
			if err != nil {
				fmt.Println("Error releasing lock:", err)
				// return
			}
			fmt.Println("lock released!")
			lockTime++
			client.Set(attributeKey, lockTime, 0)

			if lockTime > 6 {
				fmt.Println("---- End Interleaving ----")
			}
		}
	}
	// elapsed := time.Since(start)
	// fmt.Println("time required: ", elapsed.Seconds())
}

func main() {

	// Create a new Redis client
	client := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	mutexKey := "my_lock"
	attributeKey := "shared_attribute"

	input := os.Args[1:]
	if len(input) != 3 {
		println("Usage: counter_id ip_address crdt_socket_server Replicas'_Addresses.txt")
		os.Exit(1)
	}

	//establish connections using the addresses from the first input file
	//read the execution steps from the second input file
	//execute the script
	var err error
	var id int
	if id, err = strconv.Atoi(input[0]); err != nil {
		panic(err)
	}
	ip_address := input[1]
	hosts = ReadFile(input[2])

	// Start the server and listen for incoming connections.
	fmt.Println("Starting " + connType + " server on " + ip_address)
	l, err := net.Listen(connType, ip_address)
	if err != nil {
		fmt.Println("Error listening:", err.Error())
		os.Exit(1)
	}
	// Close the listener when the application closes.
	defer l.Close()

	intls_count := 0

	go func() {
		// run loop forever, until exit.
		for {
			// Listen for an incoming connection.
			c, err := l.Accept()
			if err != nil {
				fmt.Println("Error connecting:", err.Error())
				return
			}
			fmt.Println("Client connected.")

			// Print client connection address.
			fmt.Println("Client " + c.RemoteAddr().String() + " connected.")

			// Handle connections concurrently in a new goroutine.
			go handleConnection(c)
		}
	}()

	//tool.Start_inter()
	ilh := &IL_Helper{}
	// for i := 0; i < total_ils; i++ {
	ilh.start(10, func() {
		// Initialize the shared attribute value to 0
		client.Set(attributeKey, 1, 0)

		counter = NewCounter(id)
		fmt.Println()
		if intls_count == 0 {
			actions := ReadFile("../FirstRun/Actions.txt")
			go do_actions(actions, mutexKey, attributeKey, client)

			time.Sleep(5 * time.Second)
			/*if counter.id == 1 {
				cmd := exec.Command("../interleave")
				_, err := cmd.Output()
				if err != nil {
					fmt.Println("Error Running Interleavings Generator:", err)
				}

				output, _ := exec.Command("sh", "-c", "ls ../interleavings/ -1 | wc -l").Output()
				// Convert the output to an integer
				total_ils, _ := strconv.Atoi(strings.TrimSpace(string(output)))
				fmt.Println("total_ils: ", total_ils)
			}*/
			time.Sleep(5 * time.Second)
		} else {
			fmt.Println("#### Start Interleaving: ", intls_count, " ####")
			actions := ReadFile("../interleavings/ils_" + strconv.Itoa(intls_count) + ".txt")
			go do_actions(actions, mutexKey, attributeKey, client)

			time.Sleep(10 * time.Second)
			// t := new(testing.T)
			// TestFinalValue(t, counter.value)
			ilh.testFinalValue(counter.Value, 2)
		}
		intls_count++
	})
	// tool.AddAssertion(assertion1())
	// tool.AddAssertion(assertion2())
	// tool.AddAssertion(assertion3())
	// tool.End_Inter()
}

// handleConnection handles logic for a single connection request.
func handleConnection(conn net.Conn) {
	// Buffer client input until a newline.
	//buffer, err := bufio.NewReader(conn).ReadBytes('\n')

	/*
		buffer := make([]byte, 1088)
		//c := bufio.NewReader(conn)
		fmt.Println("starting to read")
		_, err := conn.Read(buffer)
		// Close left clients.
		if err != nil {
			fmt.Println("Client left.")
			conn.Close()
			return
		}
	*/

	reader := bufio.NewReader(conn)
	reqs, err := reader.ReadBytes('\n')
	if err != nil {
		fmt.Println("Client left.")
		conn.Close()
		return
	}

	rid, updates := FromMarshalData(reqs)
	// fmt.Println(updates)
	counter.Merge(rid, updates)

	// Restart the process.
	handleConnection(conn)
}
