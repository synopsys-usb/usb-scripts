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

## Reading and Writing Registers

The following commands reads or writes to a register at an offset. The
command determines which device two write to by examining the bus and
using the first DWC USB controller that it finds. If there are
multiple controllers on the bus, use the controller specific rreg and
wreg commands.

- rreg - Reads a register at an offset.
- wreg - Writes a register at an offset.
