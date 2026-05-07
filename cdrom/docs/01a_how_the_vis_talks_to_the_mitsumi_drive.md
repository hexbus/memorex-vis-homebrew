# How the VIS Talks to the Mitsumi CD-ROM Drive

This is the plain-English mental model for the VIS CD-ROM path. The key idea is that there are several layers, and each layer has its own “commands.”

The simplest version:

```text
DOS/MSCDEX talks to the embedded ROM driver.
The embedded ROM driver talks to the physical Mitsumi drive.
The replacement hardware needs to emulate the physical Mitsumi drive side.
```

## 1. The boot/title-launch path

When the VIS boots and gets ready to launch a title, the path looks like this:

```text
TLAUNCH
  -> asks DOS to open/read A:\CONTROL.TAT
  -> ROM MSCDEX layer handles the CD filesystem
  -> MSCDEX calls the embedded Mitsumi/Gryphon CD-ROM driver
  -> the driver sends Mitsumi command bytes to the drive
  -> the drive returns status and sector data
```

So when TLAUNCH reads:

```text
A:\CONTROL.TAT
```

it is not directly talking to the drive. It is using normal DOS file calls. The ROM’s MSCDEX layer turns those file reads into CD-ROM sector reads.

## 2. MSCDEX talks to the ROM driver

The embedded CD-ROM driver is registered as:

```text
MSCD001
```

MSCDEX finds it by looking for the `MSCD00` prefix.

Once found, MSCDEX sends driver request commands such as:

```text
00h  INIT
0Dh  DEVICE OPEN
0Eh  DEVICE CLOSE
80h  extended read/transfer request
88h  media ready/change request
```

These are **not physical Mitsumi drive commands**. They are requests sent to the ROM driver.

The most important one for title loading is:

```text
80h
```

That is the ROM driver’s main sector-read/transfer request.

## 3. The ROM driver talks to the physical drive

After the ROM driver receives request `80h`, it prepares a real Mitsumi drive command.

The driver:

```text
1. figures out what sector MSCDEX needs
2. converts that sector address into CD minute/second/frame format
3. stores those values in internal variables
4. sends a Mitsumi read command to the drive
```

The important Mitsumi read packet is:

```text
C0 M S F 00 00 count
```

Meaning:

```text
C0     Mitsumi read command
M      BCD minute
S      BCD second
F      BCD frame
count  number of sectors to read
```

So the key distinction is:

```text
80h = request sent to the ROM driver
C0h = read command sent by the ROM driver to the physical Mitsumi drive
```

The replacement hardware will never see `80h`. It needs to respond to `C0h`.

## 4. The driver uses internal variables to reach the hardware

The ROM driver has internal variables that appear to hold the I/O ports used to communicate with the drive:

```text
0x0061  command/data port candidate
0x0063  status/phase port candidate
```

Those are not commands. They are memory locations inside the driver.

The driver writes command bytes conceptually like this:

```text
load drive command/data port from 0x0061
write 40h, 50h, 90h, C0h, etc. to that port
```

And it checks drive status roughly like this:

```text
load status/phase port from 0x0063
poll until the drive is ready
read the response/status byte from 0x0061
```

## 5. The physical bus is the Mitsumi 40-pin interface

At the hardware level, the Mitsumi drive uses an 8-bit proprietary bus:

```text
HA0 / HA1       register select
HD0-HD7         8-bit data bus
IOR* / IOW*     read/write strobes
ENABLE*         device select
IRQ             interrupt
DRQ / DACK*     optional DMA handshake
```

So the software flow eventually becomes physical bus activity:

```text
ROM driver writes C0h to port 0x0061
  -> VIS controller/glue logic
  -> Mitsumi bus selected by HA0/HA1
  -> byte appears on HD0-HD7
  -> IOW* strobes the command into the drive
```

The drive then responds with status, phase changes, interrupts, and eventually sector data.

## 6. What a replacement engine must emulate

A BlueSCSI-style replacement should not emulate SCSI for this port. It should emulate the **drive side of the Mitsumi CD-ROM interface**.

For a first data-only homebrew prototype, the minimum commands are probably:

```text
40h  status
50h  set drive mode
70h  hold / pause
90h  configure
10h  TOC / disk info
DCh  version
C0h  read sector(s)
```

The most important command is:

```text
C0 M S F 00 00 count
```

The replacement should convert `M:S:F` back into an ISO sector number, read that 2048-byte sector from the SD card, and return the data in the way the VIS driver expects.

## 7. The CONTROL.TAT milestone

For the Title Sampler ISO, `CONTROL.TAT` was found at:

```text
/CONTROL.TAT
LBA 28
size 501 bytes
```

So the first replacement-engine milestone is:

```text
VIS asks for A:\CONTROL.TAT
  -> MSCDEX asks the ROM driver for the needed sector
  -> ROM driver sends C0 read packet to the drive
  -> replacement engine returns the sector containing CONTROL.TAT
```

If the VIS can read `A:\CONTROL.TAT`, then the basic CD-ROM data path is working.

## Short version

```text
DOS/MSCDEX talks to the ROM driver using driver requests like 80h.

The ROM driver talks to the physical Mitsumi drive using commands like C0h.

The replacement hardware needs to emulate the Mitsumi drive, not DOS, MSCDEX, or SCSI.
```

That is the core mental model for the VIS CD-ROM path.
