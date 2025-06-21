package main

// Implementing TCP RFC-793
// https://datatracker.ietf.org/doc/html/rfc793


import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:sys/linux"

// 16 bit Source Port
// 16 bit Destination Port
// 32 bit sequence number
// 32 bit acknowledgement number
// 4 bit data offset
// 6 bit reserved
// 6 control bits
//
//
//
//

ConnectionStates :: enum {
	LISTEN,
	SYN_SENT,
	SYN_RECV,
	ESTABLISHED,
	FIN_WAIT_1,
	FIN_WAIT_2,
	CLOSE_WAIT,
	CLOSING,
	LAST_ACK,
	TIME_WAIT,
}

// These need to be in reverse order due to the way
// bit fields are stored
Offset_Reserved_ControlBits :: bit_field u16be {
	FIN:      u8 | 1,
	SYN:      u8 | 1,
	RST:      u8 | 1,
	PSH:      u8 | 1,
	ACK:      u8 | 1,
	URG:      u8 | 1,
	reserved: u8 | 6,
	offset:   u8 | 4,
}

TCP_Header :: struct #packed {
	src_port:           u16be,
	dest_port:          u16be,
	seq_num:            u32be,
	ack_num:            u32be,
	offset_res_control: Offset_Reserved_ControlBits,
	window:             u16be,
	checksum:           u16be,
	urgent_ptr:         u16be,
}

main :: proc() {
	sockflags := bit_set[linux.Socket_FD_Flags_Bits;int]{}
	sock, err := linux.socket(
		linux.Address_Family.INET,
		linux.Socket_Type.RAW,
		sockflags,
		linux.Protocol.TCP,
	)
	if err != linux.Errno.NONE {
		fmt.println("Some error", err)
		os.exit(1)
	}
	defer linux.close(sock)

	h := TCP_Header {
		src_port = cast(u16be)8080,
		dest_port = cast(u16be)8081,
		seq_num = cast(u32be)1,
		ack_num = cast(u32be)2,
		offset_res_control = Offset_Reserved_ControlBits {
			offset = 0,
			reserved = 63,
			URG = 1,
			ACK = 0,
			PSH = 1,
			RST = 0,
			SYN = 1,
			FIN = 0,
		},
	}
	buf := transmute([2]u8)h.offset_res_control
	fmt.printfln("Wire order: %02X %02X\n", buf[0], buf[1])
	tcp_bytes := transmute([size_of(TCP_Header)]u8)h
	for b in tcp_bytes {
		fmt.printf("%08b\n", b)
	}
}
