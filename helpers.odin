package main

import "core:fmt"

binary_dump :: proc(bytes: []u8) {
	for b in bytes {
		fmt.printf("%08b\n", b)
	}
}

hex_dump :: proc(bytes: []u8) {
	for i := 0; i < len(bytes); i += 1 {
		fmt.printf("%2X ", bytes[i])
		if i % 4 == 3 {
			fmt.println()
		}
	}
}
