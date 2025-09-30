package cluster

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"
)

func randomInterleave(events []string, visitedPaths map[string]bool) {
	n := len(events)

	for len(visitedPaths) < factorial(n) {
		shuffledEvents := shuffleArray(append([]string{}, events...))
		path := strings.Join(shuffledEvents, ",")

		if !visitedPaths[path] {
			visitedPaths[path] = true
			fmt.Println(path)
		}
	}
}

func shuffleArray(array []string) []string {
	rand.Seed(time.Now().UnixNano())
	for i := len(array) - 1; i > 0; i-- {
		j := rand.Intn(i + 1)
		array[i], array[j] = array[j], array[i]
	}
	return array
}

func factorial(n int) int {
	result := 1
	for i := 2; i <= n; i++ {
		result *= i
	}
	return result
}

func readEventsFromFile(filename string) []string {
	file, err := os.Open(filename)
	if err != nil {
		fmt.Println("Error reading file:", err)
		return nil
	}
	defer file.Close()

	var events []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		events = append(events, strings.TrimSpace(scanner.Text()))
	}

	if err := scanner.Err(); err != nil {
		fmt.Println("Error reading file:", err)
	}

	return events
}
