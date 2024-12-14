## Datasheet

### Overview
The `i2s` IP is a fully parameterised soft IP implementing the 	Philips compatible I2S interface. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0. Now only support keyboard.

### Feature
* Compatible with Phillps I2S standard
* Half duplex serial data transmission(send or receive only)
* Audio CODEC master or slave mode support
* Programmable serial clock polarity
* Programmable prescaler
    * max division factor is up to 2^16
    * 8KHz, 12KHz, 16KHz, 24KHz, 32KHz, 48KHz or 96KHz sample rate
* Stereo or left channel and right channel only mode
* MSB-justified, LSB-justified or I2S Phillps mode
* 8, 16, 24 or 32 bits data transmission size
* Independent send and receive FIFO
    * 16~64 data depth
    * empty or no-emtpy status flag
* Maskable send or receive interrupt and programmable threshold
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |
| i2c ->    | interface   | i2c slave interface |
| `i2c.scl_i` | input | i2c clock input |
| `i2c.scl_o` | output | i2c clock output |
| `i2c.scl_dir_o` | output | i2c clock tri-state ctrl |
| `i2c.sda_i` | input | i2c data input |
| `i2c.sda_o` | output | i2c data output |
| `i2c.sda_dir_o` | output | i2c data tri-state ctrl |
| `i2c.irq_o` | output | i2c irq output |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL](#control-register) | 0x0 | 4 | control register |
| [DIV](#divide-reigster) | 0x4 | 4 | divide register |
| [TXR](#transmit-reigster) | 0x8 | 4 | transmit register |
| [RXR](#receive-reigster) | 0xC | 4 | receive register |
| [STAT](#state-reigster) | 0x10 | 4 | state register |

#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:26]` | none | reserved |
| `[25:21]` | RW | RXTH |
| `[20:16]` | RW | TXTH |
| `[15:14]` | RW | DTL |
| `[13:12]` | RW | CHL |
| `[11:10]` | RW | CHM |
| `[9:8]`   | RW | FMT |
| `[7:7]`   | RW | WM |
| `[6:6]`   | RW | LSB |
| `[5:5]`   | RW | POL |
| `[4:4]`   | RW | LSR |
| `[3:3]`   | RW | CLR |
| `[2:2]`   | RW | RXIE |
| `[1:1]`   | RW | TXIE |
| `[0:0]`   | RW | EN |

reset value: `0x0000_0000`

* RXTH: receive fifo irq trigger threshold

* TXTH: transmit fifo irq trigger threshold

* DTL: data size in one transmit
    * `DTL = 2'b00`: 8 bits
    * `DTL = 2'b01`: 16 bits
    * `DTL = 2'b10`: 24 bits
    * `DTL = 2'b11`: 32 bits

* CHL: 
    * `CHL = 2'b00`: 8 bits
    * `CHL = 2'b01`: 16 bits
    * `CHL = 2'b10`: 24 bits
    * `CHL = 2'b11`: 32 bits

* CHM: mode
    * `CHM = 2'b00`: stero mode
    * `CHM = 2'b01`: left channel
    * `CHM = 2'b10`: right channel
    * `CHM = 2'b11`: none

#### Prescaler Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | RW | PSCR |

reset value: `0x0000_FFFF`

* PSCR: 16-bit prescaler value

#### Transmit Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:8]` | none | reserved |
| `[7:0]` | RW | DATA |

reset value: `0x0000_0000`

* DATA: transmit data
    * `[7:1]`: upper 7 bits of DATA
    * `[0:0]`: LSB of DATA
        * address phase: `0` -> write to slave `1` -> read from slave
        * data phase: LSB of DATA

#### Receive Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:8]` | none | reserved |
| `[7:0]` | RO | DATA |

reset value: `0x0000_0000`

* DATA: receive data

#### Command Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:8]` | none | reserved |
| `[7:7]` | WO | STA |
| `[6:6]` | WO | STO |
| `[5:5]` | WO | RD |
| `[4:4]` | WO | WR |
| `[3:3]` | WO | ACK |
| `[2:1]` | none | reserved |
| `[0:0]` | WO | IACK |

reset value: `0x0000_0000`

* STA: start command
    * `STA = 1'b0`: dont send start command
    * `STA = 1'b1`: otherwise

* STO: stop command
    * `STO = 1'b0`: dont send stop command
    * `STO = 1'b1`: otherwise

* RD: read from slave command
    * `RD = 1'b0`: dont send read command
    * `RD = 1'b1`: otherwise

* WR: write to slave command
    * `WR = 1'b0`: dont send write command
    * `WR = 1'b1`: otherwise

* ACK: read acknowledge
    * `ACK = 1'b0`: send nack command
    * `ACK = 1'b1`: send ack command

* IACK: interrupt acknowledge
    * `IACK = 1'b0`: dont clear interrupt ack flag
    * `IACK = 1'b1`: otherwise

#### State Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:8]` | none | reserved |
| `[7:7]` | RO | RXK |
| `[6:6]` | RO | BSY |
| `[5:5]` | RO | AL |
| `[4:2]` | none | reserved |
| `[1:1]` | RO | TIP |
| `[0:0]` | RO | IF |

reset value: `0x0000_0000`

* RXK: receive acknowledge from slave
    * `RXK = 1'b0`: receive ack
    * `RXK = 1'b1`: otherwise

* BSY: i2c bus busy
    * `BSY = 1'b0`: detect stop command
    * `BSY = 1'b1`: detect start command

* AL: arbitration lost
    * `AL = 1'b0`: dont lost arbit
    * `AL = 1'b1`: otherwise

* TIP: transmit in progress
    * `TIP = 1'b0`: transmit done
    * `TIP = 1'b1`: otherwise

* IF: interrupt flag
    * `IF = 1'b0`: interrupt is triggered
    * `IF = 1'b1`: otherwise

### Program Guide
These registers can be accessed by 4-byte aligned read and write. C-like pseudocode init operation:
```c
i2c.PSCR = PSCR_16_bit // set the prescaler value
i2c.CTRL.EN = 1        // enable i2c core

```

write operation:
```c
i2c.TXR = (SLAVE_ADDR_7_bit << 1) | 0 // send slave device addr
i2c.CMD.[STA, WR] = 1                 // set start and write mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')


i2c.TXR = SLAVE_SUB_ADDR_8_bit        // send slave sub addr
i2c.CMD.WR = 1                        // set start and write mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')

...
i2c.TXR = DATA_8_bit                  // send data
i2c.CMD.WR = 1                        // set start and write mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')
...

i2c.CMD.STOP = 1                      // send stop command
while (i2c.SR.BSY == 1)               // wait bus idle
```

read operation:
```c
i2c.TXR = (SLAVE_ADDR_7_bit << 1) | 0 // send slave device addr
i2c.CMD.[STA, WR] = 1                 // set start and write mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')


i2c.TXR = SLAVE_SUB_ADDR_8_bit        // send slave sub addr
i2c.CMD.WR = 1                        // set start and write mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')

i2c.CMD.STOP = 1                      // send stop command
while (i2c.SR.BSY == 1)               // wait bus idle

i2c.TXR = (SLAVE_ADDR_7_bit << 1) | 1 // send slave device addr
i2c.CMD.[STA, WR] = 1                 // set start and write mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')

...
i2c.CMD.RD = 1                        // set read mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')
uint32_t recv_data = i2c.RXR          // read the data
...
i2c.CMD.[STOP, RD] = 1                // set stop and read mode
while (i2c.SR.TIP == 0);              // need TIP go to 1
while (i2c.SR.TIP != 0);              // need TIP go to 0
if i2c.SR.RXK == 1: print('no receive ack')
uint32_t recv_data = i2c.RXR          // read the last data

```
### Resoureces
### References
### Revision History