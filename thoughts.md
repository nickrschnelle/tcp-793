# TCP RFC-793 thoughts

## Structure

tcp.odin - contains everything related to the tcp header
ip.odin - contains everything related to the ip header (RFC-791)
server.odin - contains server code
client.odin - contains client code
main.odin - simple cli that prompts the user if they want to spin up a client or server & asks for port

## TODO

Current state:

- Basic CLI that prompts if user wants to start a client or server
- When starting a client, user is prompted for a payload
- Payload is sent with a bare minimum IP header to the sever
- Server prints the hex dump of the received packet

Next steps:

- Clean up client prompt for payload, it isn't clearly labelled
- Add a build script to output proper executable name
- Allow user to choose method of payload
    - basic string input
    - path to file
- Add TCP header for initial 3 way hand shake
- Complete 3 way handshake
- Successfully send payload via TCP to server and print it
- Turn project into library so it can be used for future projects (implement HTTP)
