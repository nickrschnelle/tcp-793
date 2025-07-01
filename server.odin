package main

import "core:fmt"
import "core:os"
import l "core:sys/linux"

server_init :: proc(client_port: u16, server_port: u16) {
	CLIENT_PORT := cast(u16be)client_port
	SERVER_PORT := cast(u16be)server_port
	ADDR := [4]u8{127, 0, 0, 1}

	sockflags := bit_set[l.Socket_FD_Flags_Bits;int]{}
	sock, err := l.socket(l.Address_Family.INET, l.Socket_Type.RAW, sockflags, l.Protocol(253))
	if err != l.Errno.NONE {
		fmt.println("error creating socket", err)
		os.exit(1)
	}
	defer l.close(sock)

	buf := make([]u8, 4096)
	addr := l.Sock_Addr_In {
		sin_port   = SERVER_PORT,
		sin_addr   = ADDR,
		sin_family = l.Address_Family.INET,
	}

	bind_err := l.bind(sock, &addr)
	if bind_err != l.Errno.NONE {
		fmt.println("binding error", err)
		os.exit(1)
	}

	fmt.println("listening on port: ", SERVER_PORT)

	for {
		n, err := l.recv(sock, buf, bit_set[l.Socket_Msg_Bits;i32]{})
		if err != l.Errno.NONE {
			fmt.println("recv error: ", err)
			continue
		}

		if n > 0 {
			fmt.println("Received ", n, " bytes")
			fmt.print("Data: ")
			for i in 0 ..< n {
				fmt.printf("%02X", buf[i])
			}
			fmt.println()
		}
	}
}
