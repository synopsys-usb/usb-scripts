#!/bin/bash

__complete_audio()
{
    local arg=${COMP_WORDS[COMP_CWORD - 1]}

    if [ "$arg" = "audio" ]; then
        COMPREPLY=( `echo -n "$COMP_LINE" | audio completion` )
    else
        COMPREPLY=( `echo -n "$COMP_LINE" | audio audio_completion` )
    fi
}

__complete_dwc2()
{
    COMPREPLY=( `echo -n "$COMP_LINE" | dwc2 completion` )
}

__complete_dwc3()
{
    local arg=${COMP_WORDS[1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( `echo -n "$COMP_LINE" | dwc3 completion` )
    elif [ $COMP_CWORD -eq 2 ]; then
        if [ "$arg" = "load" ] || [ "$arg" = "audio" ]; then
            COMPREPLY=( `echo -n "$COMP_LINE" | dwc3 $arg completion` )
        fi
    elif [ $COMP_CWORD -ge 3 ]; then
        if [ "$arg" = "audio" ]; then
            __complete_audio
        fi
    fi
}

__complete_dwc3_xhci()
{
    COMPREPLY=( `echo -n "$COMP_LINE" | dwc3-xhci completion` )
}

complete -F __complete_audio audio
complete -F __complete_dwc2 dwc2
complete -F __complete_dwc3 dwc3
complete -F __complete_dwc3_xhci dwc3-xhci
