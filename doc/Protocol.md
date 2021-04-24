
- Protocol packets are composed of 32-bit words
- Packets are variable width, with the smallest being a single word
- Packets encode burst information

- Need to have ingress and egress nodes
- Some nodes will only be 
- Offchip accesses are re-decoded at the egress node

# Packet Header
- 31:30  - Dst Tile X
- 29:28  - Dst Tile Y
- 27:26  - Dst Chip X
- 25:24  - Dst Chip Y
- 23:22  - Src Tile X
- 21:20  - Src Tile Y
- 19:18  - Src Chip X
- 17:16  - Src Chip Y

- 15     - Offchip    -- Destination is offchip
- 14:12  - Opcode
           - Read
           - Write
           - AMO
           - IRQ
- 11:8   - Data Mask
- 7:4    - Transaction ID
- 3:0    - Size 0,1,2,4,8,16 (0,1,2,3,4,5)
         - Total payload size (Address+Data)
         - Ensures that routers can be fairly simple and autonomous

# Address -- for 
- 31:0   - Address

# Data
- 31:0   - Data

- Can we assume writes are unacknowledged?
-> We'd probably need to provide two variants

- Can't assume a fixed view of routing

- 31: Dest off-noc
- 

