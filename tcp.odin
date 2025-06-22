package main

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

TCP_ConnectionStates :: enum {
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
TCP_Offset_Reserved_ControlBits :: bit_field u16be {
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
	offset_res_control: TCP_Offset_Reserved_ControlBits,
	window:             u16be,
	checksum:           u16be,
	urgent_ptr:         u16be,
}
