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
directory of `<path>`. This directory must be added to your PATH
environment variable.

```
export PATH=$PATH:<path>/dwc_utils
```

To add bash command line completions:

```
source <path>/dwc_utils/completions.sh
```

## Usage Instructions

The commands are divided into 3 types:
* dwc3
* dwc3-xhci
* dwc2

To list all the available commands enter the type:

```
$ dwc3
```

To execute a command:
```
$ dwc3 <command>
```

For example, to load dwc3 peripheral module:
```
$ dwc3 load
```
