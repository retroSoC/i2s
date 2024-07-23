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