package main

import "fmt"

func main() {
	array := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	var result int
	result = array[0]
	for i := 0; i < len(array); i++ {
		if array[i] < result {
			result = array[i]
		}
	}
	fmt.Println(result)
}
