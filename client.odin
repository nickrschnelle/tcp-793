package main

// Implementing TCP RFC-793
// https://datatracker.ietf.org/doc/html/rfc793


import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:slice"
import l "core:sys/linux"

client_start :: proc(client_port: u8, server_port: u8) {
	CLIENT_PORT := cast(u16be)client_port
	SERVER_PORT := cast(u16be)server_port
	ADDR := [4]u8{127, 0, 0, 1}

	sockflags := bit_set[l.Socket_FD_Flags_Bits;int]{}
	sock, err := l.socket(l.Address_Family.INET, l.Socket_Type.RAW, sockflags, l.Protocol.TCP)
	if err != l.Errno.NONE {
		fmt.println("error creating socket", err)
		os.exit(1)
	}
	defer l.close(sock)

	addr := l.Sock_Addr_In {
		sin_port   = CLIENT_PORT,
		sin_addr   = ADDR,
		sin_family = l.Address_Family.INET,
	}

	h := TCP_Header {
		src_port = CLIENT_PORT,
		dest_port = SERVER_PORT,
		seq_num = cast(u32be)1,
		ack_num = cast(u32be)0,
		offset_res_control = TCP_Offset_Reserved_ControlBits {
			offset = 0,
			reserved = 0,
			URG = 0,
			ACK = 0,
			PSH = 0,
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
