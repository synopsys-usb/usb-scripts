# DWC USB Scripts

This repository contains scripts, tools, and utilties for running and
debugging DWC USB controllers in various development environments. It
supports HAPS development boards operating in a PC environment and
ARC-based IP Kits based on the ARC AXS101 development board.

## Building Instructions

Build all executables with the following:

```
$ make
```

## Installation Instructions

To install to a custom directory:

```
$ make prefix=<path> install
```

All files and libraries will be installed into the `dwc_utils` sub
directory of <path>. Add this directory must be added to your PATH
environment variable.

```
export PATH=$PATH:<path>/dwc_utils
```

To add bash command line completions

```
source <path>/dwc_utils/completions.sh
```

## Usage Instructions

The commands are divided into 3 types:
* dwc3
* dwc3-xhci
* dwc2

dwc3 and dwc2 are peripheral types while dwc3-xhci is host. To invoke
a command, it must be prefixed with a specific type (with an exception
to rreg and wreg). To list all the commands of a type and a description
for each, enter the type:
```
$ dwc3
```

The example above will return this:
```
usage: dwc3 <command>

Commands:
  enable_trace    Enable dwc3 driver trace
  info            Print information about the controller
  load            Load the dwc3 module
  regdump         Print all dwc3 registers
  rreg            Read register
  trace           Print dwc3 driver trace
  unload          Unload the dwc3 module
  wreg            Write register
```

To execute a command:
```
$ dwc3 <command>
```

For example, to load dwc3 host modules,
```
$ dwc3-xhci load
```

## Reading and Writing Registers

The following commands reads or writes to a register at an offset. The
command determines which device to write to by examining the bus and
using the first DWC USB controller that it finds. If there are
multiple controllers on the bus, use the controller specific rreg and
wreg commands.

- rreg - Reads a register at an offset.
- wreg - Writes a register at an offset.

These commands do not need a type to be executed.

To read a register:
```
$ rreg <offset> [<bits>]
```

For example,
```
$ rreg c120 15:0

Register: c120
Hex: 5533310a
Binary: 0101 0101 0011 0011 0011 0001 0000 1010

Bits [15:0]:
  Hex: 310a
  Decimal: 12554
  Binary: 0011000100001010

D15         D12             D8              D4              D0
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
| 0   0   1   1   0   0   0   1   0   0   0   0   1   0   1   0 |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
```

To write a value to a register:
```
$ wreg <offset> <value> [<bits>]
```
Write \<value\> to the register at \<offset\>. If writing to a bitfield,
the bitfield is set by read-modify-write.

For example,
```
$ wreg c110 2 13:12
```
The value 2 is written to bit set 13:12 at the offset c110.

