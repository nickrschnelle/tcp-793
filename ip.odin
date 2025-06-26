package main

import "core:fmt"

IP_Flags_Fragment_Offset :: bit_field u16be {
	fragment_offset: u16be | 13,
	flags:           u8    | 3,
}

IP_Header :: struct #packed {
	version_ihl:          u8,
	tos:                  u8,
	total_length:         u16be,
	identification:       u16be,
	flags_fagment_offset: IP_Flags_Fragment_Offset,
	ttl:                  u8,
	protocol:             u8,
	checksum:             u16be,
	src_addr:             [4]u8,
	dest_addr:            [4]u8,
	// TODO: what do here
	//options:              u32be,
}

generate_ip_header :: proc(src_addr: [4]u8, dest_addr: [4]u8, payload_len: u16) -> IP_Header {
	h := IP_Header {
		// 0100 0101 (first 4 bits = 4 for version, 2nd 4 bits = 5 for ihl)
		version_ihl = (4 << 4) | 5,
		tos = 0,
		total_length = cast(u16be)(20 + payload_len),
		identification = cast(u16be)1234,
		flags_fagment_offset = IP_Flags_Fragment_Offset{fragment_offset = 0, flags = 0},
		ttl = 63,
		protocol = 253,
		checksum = 0,
		src_addr = src_addr,
		dest_addr = dest_addr,
	}

	ptr := &h
	//data := (^[]u8)(&h)^
	data := transmute([size_of(IP_Header)]u8)h
	fmt.println("BEFORE CHECKSUM")
	hex_dump(data[:])
	ptr.checksum = cast(u16be)generate_checksum(data[:])
	data = transmute([size_of(IP_Header)]u8)h
	fmt.println("AFTER CHECKSUM")
	hex_dump(data[:])

	return h
}

generate_checksum :: proc(data: []u8) -> u16 {
	sum: u32 = 0

	// 2 bytes at a time
	for i := 0; i < len(data); i += 2 {
		// grab the first byte and shift it into the upper 8 bits
		word: u16 = cast(u16)data[i] << 8
		if i + 1 < len(data) {
			// bitwise OR with the next byte so we have both bytes next to each other in the
			// 16 bit word
			word |= cast(u16)data[i + 1]
		}

		// add the 16 bit word to the sum
		sum += cast(u32)word
	}

	// if we shift right 16 bits and there's any left over then we have carry bits to add
	for sum >> 16 != 0 {
		// XOR the sum with 0xFFFF to get just the bottom 16 bits
		// and add that to sum >> 16 (only the carry bits)
		sum = (sum & 0xFFFF) + (sum >> 16)
	}

	// flip the bits to return one's compliment
	return ~cast(u16)sum
}
