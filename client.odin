package main

// Implementing TCP RFC-793
// https://datatracker.ietf.org/doc/html/rfc793


import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import l "core:sys/linux"

prompt_payload :: proc() -> string {
	input, err := get_input()
	return input
}

client_init :: proc(client_port: u8, server_port: u8) {
	CLIENT_PORT := cast(u16be)client_port
	SERVER_PORT := cast(u16be)server_port
	ADDR := [4]u8{127, 0, 0, 1}

	sockflags := bit_set[l.Socket_FD_Flags_Bits;int]{}
	sock, err := l.socket(l.Address_Family.INET, l.Socket_Type.RAW, sockflags, l.Protocol.TCP)
	if err != l.Errno.NONE {
		fmt.println("error creating client socket", err)
		os.exit(1)
	}
	defer l.close(sock)

	ip := generate_ip_header([4]u8{127, 0, 0, 1}, [4]u8{127, 0, 0, 1}, 0)
	addr := l.Sock_Addr_In {
		sin_port   = CLIENT_PORT,
		sin_addr   = ADDR,
		sin_family = l.Address_Family.INET,
	}

	bind_err := l.bind(sock, &addr)
	if bind_err != l.Errno.NONE {
		fmt.println("error binding client socket", err)
		os.exit(1)
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
}
