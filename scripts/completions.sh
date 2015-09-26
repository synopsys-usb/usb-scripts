#!/bin/bash

__complete_dwc2()
{
    COMPREPLY=( `echo -n "$COMP_LINE" | dwc2 completion` )
}

__complete_dwc3()
{
    COMPREPLY=( `echo -n "$COMP_LINE" | dwc3 completion` )
}

__complete_dwc3_xhci()
{
    COMPREPLY=( `echo -n "$COMP_LINE" | dwc3-xhci completion` )
}

complete -F __complete_dwc2 dwc2
complete -F __complete_dwc3 dwc3
complete -F __complete_dwc3_xhci dwc3-xhci
