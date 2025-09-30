package cluster

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func dfs(path []string, remainingEvents []string, visitedPaths map[string]bool) {
	if len(remainingEvents) == 0 {
		fmt.Println(strings.Join(path, ","))
		return
	}

	for i := 0; i < len(remainingEvents); i++ {
		newPath := append([]string{}, path...)
		newRemaining := append([]string{}, remainingEvents...)

		newPath = append(newPath, remainingEvents[i])
		newRemaining = append(newRemaining[:i], newRemaining[i+1:]...)

		newPathString := strings.Join(newPath, ",")

		if !visitedPaths[newPathString] {
			visitedPaths[newPathString] = true
			dfs(newPath, newRemaining, visitedPaths)
		}
	}
}

func ReadEventsFromFile(filename string) []string {
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
