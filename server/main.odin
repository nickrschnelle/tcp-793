package main

import "core:fmt"
import "core:os"
import "core:sys/linux"

main :: proc() {
	PORT: u16be = 8081
	ADDR := [4]u8{127, 0, 0, 1}

	sockflags := bit_set[linux.Socket_FD_Flags_Bits;int]{}
	sock, err := linux.socket(
		linux.Address_Family.INET,
		linux.Socket_Type.RAW,
		sockflags,
		linux.Protocol.TCP,
	)
	if err != linux.Errno.NONE {
		fmt.println("error creating socket", err)
		os.exit(1)
	}
	defer linux.close(sock)

	buf := make([]u8, 4096)
	addr := linux.Sock_Addr_In {
		sin_port   = PORT,
		sin_addr   = ADDR,
		sin_family = linux.Address_Family.INET,
	}

	bind_err := linux.bind(sock, &addr)
	if bind_err != linux.Errno.NONE {
		fmt.println("binding error", err)
		os.exit(1)
	}

	fmt.println("listening on port: ", PORT)

	for {
		n, err := linux.recv(sock, buf, bit_set[linux.Socket_Msg_Bits;i32]{})
		if err != linux.Errno.NONE {
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
