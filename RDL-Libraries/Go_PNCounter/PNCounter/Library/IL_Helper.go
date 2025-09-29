package main

import "fmt"

type IL_Helper struct{}

func (ilh *IL_Helper) start(total int, codeBlock func()) {
	for i := 0; i < total; i++ {
		codeBlock()
	}
}

func (ilh *IL_Helper) testFinalValue(finalValue func() int, expected int) {
	if finalValue() == expected {
		fmt.Println()
		fmt.Println("PASS")
		fmt.Println()
	} else {
		fmt.Println()
		fmt.Println("FAIL")
		fmt.Println()
	}
}
