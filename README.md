# Packet-Parser

## Overview

This project implements a simple **packet parser** in **SystemVerilog**. The parser receives a stream of incoming packet bytes and extracts the packet header fields such as the **Destination Address**, **Source Address**, and **Packet Type**, while allowing the payload to continue through the datapath.

This project is intended as a learning exercise for understanding streaming digital designs, finite state machines (FSMs), counters, shift registers, and packet-based communication protocols.

---

# What is a Packet?

A **packet** is a formatted unit of data transmitted over a communication network.

Instead of sending only the actual data, networking protocols add additional information before the data, called the **header**, which helps the network deliver and process the packet correctly.

A typical Ethernet packet looks like:

```
+----------------+----------------+------------+---------------+
| Destination    | Source         | Type       | Payload       |
| Address        | Address        |            |               |
|   6 Bytes      |   6 Bytes      | 2 Bytes    | Variable Size |
+----------------+----------------+------------+---------------+
```

Example packet:

```
Destination : 11 22 33 44 55 66

Source      : AA BB CC DD EE FF

Type        : 08 00

Payload      : 48 65 6C 6C 6F
```

The payload above represents the ASCII string:

```
Hello
```

---

# What is a Packet Parser?

A packet parser is a hardware block that receives packet data one word (or one byte) at a time and identifies different fields inside the packet.

Its primary responsibilities are:

- Detect the beginning of a packet
- Separate different header fields
- Store important header information
- Determine where the payload begins
- Signal when header parsing is complete

A packet parser **does not normally modify the packet**. It simply extracts useful information from the incoming stream.

---

# Why is a Packet Parser Needed?

Every network packet contains information required before the payload can be processed.

For example,

- Who sent this packet?
- Who should receive it?
- What protocol does it contain?
- Should this packet be forwarded?
- Should this packet be dropped?

Without parsing the packet header, the hardware has no idea how to process the incoming data.

---

# Where is it Used?

Packet parsers are fundamental components in networking hardware.

Applications include:

- Ethernet MACs
- Network Interface Cards (NICs)
- Routers
- Switches
- Firewalls
- SmartNICs
- Data Center Networking ASICs
- AI Accelerators with Networking Support
- Packet Inspection Engines

---

# Packet Flow

```
Ethernet Cable
      │
      ▼
 Serial Bitstream
      │
      ▼
+------------------+
|      SerDes      |
+------------------+
      │
      ▼
 Parallel Bus
      │
      ▼
+------------------+
|  Packet Parser   |
+------------------+
      │
      ├── Destination Address
      ├── Source Address
      ├── Packet Type
      └── Payload Stream
```

---

# Project Features

- SystemVerilog implementation
- FSM-based parser
- Byte-wise packet processing
- Destination address extraction
- Source address extraction
- Packet type extraction
- Payload detection
- Simple testbench
- Easy to understand architecture

---

# Interface

## Inputs

| Signal | Width | Description |
|---------|------|-------------|
| clk | 1 | System clock |
| rst | 1 | Active-high reset |
| data_in | 8 | Incoming packet byte |
| data_valid | 1 | Indicates valid input data |
| sop | 1 | Start of packet |

---

## Outputs

| Signal | Width | Description |
|---------|------|-------------|
| dest_addr | 48 | Destination MAC Address |
| src_addr | 48 | Source MAC Address |
| pkt_type | 16 | Ethernet Type field |
| packet_done | 1 | Packet parsing completed |

---

# Packet Format Used

```
Bytes 0-5   : Destination Address

Bytes 6-11  : Source Address

Bytes 12-13 : Packet Type

Remaining   : Payload
```

---

# FSM

The parser operates as a Finite State Machine.

```
                +------+
                | IDLE |
                +------+
                    |
                  sop
                    |
                    ▼
               +--------+
               | DEST   |
               +--------+
                    |
               6 Bytes
                    |
                    ▼
              +---------+
              | SOURCE  |
              +---------+
                    |
               6 Bytes
                    |
                    ▼
               +--------+
               | TYPE   |
               +--------+
                    |
               2 Bytes
                    |
                    ▼
             +-------------+
             | PAYLOAD     |
             +-------------+
                    |
              Payload End
                    |
                    ▼
                +-------+
                | DONE  |
                +-------+
```

---

# Internal Registers

| Register | Width | Purpose |
|-----------|------|---------|
| dest_addr | 48 | Stores destination address |
| src_addr | 48 | Stores source address |
| pkt_type | 16 | Stores packet type |
| byte_count | 4 | Counts bytes inside each field |
| payload_count | 8 | Counts payload bytes (example implementation) |

---

# How Header Extraction Works

Each incoming byte is shifted into the corresponding register.

Example:

Incoming destination bytes

```
11
22
33
44
55
66
```

Register contents after each byte:

```
11

11 22

11 22 33

11 22 33 44

11 22 33 44 55

11 22 33 44 55 66
```

This is implemented using a shift operation such as:

```systemverilog
dest_addr <= {dest_addr[39:0], data_in};
```

The oldest bytes are shifted left by 8 bits while the newest byte is appended at the least significant end.

---

# Test Packet

The included testbench sends the following packet.

```
Destination

11 22 33 44 55 66

Source

AA BB CC DD EE FF

Type

08 00

Payload

48 65 6C 6C 6F
```

Payload in ASCII:

```
Hello
```

---

# Expected Output

```
Destination Address

112233445566

Source Address

AABBCCDDEEFF

Packet Type

0800
```

---

# Concepts Covered

This project demonstrates several important RTL design concepts.

- Finite State Machines (FSM)
- Sequential Logic
- Byte Counters
- Shift Registers
- Streaming Interfaces
- Packet Processing
- Register Design
- State Transitions
- Header Parsing
- Testbench Development

---

# Simulation

Typical simulation flow:

```
Compile RTL

↓

Compile Testbench

↓

Run Simulation

↓

Observe Waveforms

↓

Verify Header Fields
```

Useful internal signals to monitor:

- state
- byte_count
- payload_count
- dest_addr
- src_addr
- pkt_type

---

# Future Improvements

Possible enhancements include:

- End-of-Packet (EOP) support
- Variable payload length
- CRC checking
- Ethernet preamble detection
- VLAN tag parsing
- IPv4/IPv6 header parsing
- Error detection
- AXI-Stream interface
- Parameterized bus width
- Pipelined architecture

---

# Learning Outcomes

By completing this project, you will gain an understanding of:

- How packet-based communication works
- Header vs payload
- Streaming hardware architectures
- FSM-based protocol handling
- Register shifting techniques
- RTL implementation of networking hardware
- Writing and debugging SystemVerilog testbenches

---

# Repository Structure

```
├── packet_parser.sv
├── tb_packet_parser.sv
└── README.md
```

---

This project is intended for educational purposes and interview preparation.
