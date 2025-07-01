package main

import "core:fmt"
import "core:os"
import "core:strings"

get_input :: proc() -> (string, os.Error) {
	buf: [256]byte
	n, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.println("Error reading input")
		return "", err
	}
	input := string(buf[:n])
	input = strings.trim_suffix(input, "\n")
	input = strings.trim_suffix(input, "\r")
	return strings.clone(input), nil
}

main :: proc() {
	fmt.println("Welcome to TCP RFC-793\n")
	fmt.println("Please select an option:")
	fmt.println("  1)\tStart server")
	fmt.println("  2)\tStart clent")
	input, err := get_input()
	// TODO: switch
	if input == "1" {
		server_init(8080, 8081)
	}
	if input == "2" {
		client_init(8080, 8081)
	}
	defer delete(input)
}
