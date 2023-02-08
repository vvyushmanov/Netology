package main

import (
	"fmt"
)

func main() {
	fmt.Print("Enter a number: ")
	var input float64
	_, err := fmt.Scanf("%f", &input)
	if err != nil {
		fmt.Println("Not a valid number!")
		return
	}

	output := input / 0.3048

	fmt.Println(output)
}
