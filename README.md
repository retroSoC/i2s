# I2S
<p>
    <a href=".">
      <img src="https://img.shields.io/badge/RTL%20dev-in%20progress-silver?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/VCS%20sim-in%20progress-silver?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/FPGA%20verif-no%20start-wheat?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/Tapeout%20test-no%20start-wheat?style=flat-square">
    </a>
</p>

## Features
* Compatible with Phillps I2S standard
* Half duplex serial data transmission(send or receive only)
* Audio CODEC master or slave mode support
* Programmable serial clock polarity
* Programmable prescaler
    * max division factor is up to 2^16
    * 8KHz, 16KHz, 32KHz, 48KHz or 96KHz sample rate
* Stereo or left channel and right channel only mode
* MSB-justified, LSB-justified or I2S Phillps mode
* 8, 16, 24 or 32 bits data transmission size
* Independent send and receive FIFO
    * 16~64 data depth
    * empty or no-emtpy status flag
* Maskable send or receive interrupt and programmable threshold
* Static synchronous design
* Full synthesizable

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```