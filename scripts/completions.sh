#!/bin/bash

__complete_dwc2()
{
    COMPREPLY=( `echo -n "$COMP_LINE" | dwc2 completion` )
}

__complete_dwc3()
{
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( `echo -n "$COMP_LINE" | dwc3 completion` )
    elif [ $COMP_CWORD -eq 2 ]; then
        local arg=${COMP_WORDS[1]}
        if [ "$arg" = "load" ] || [ "$arg" = "audio" ]; then
            COMPREPLY=( `echo -n "$COMP_LINE" | dwc3 $arg completion` )
        fi
    elif [ $COMP_CWORD -ge 3 ]; then
        local arg1=${COMP_WORDS[1]}
        local arg2=${COMP_WORDS[2]}
        if [ "$arg1" = "audio" ] && {
            [ "$arg2" = "play" ] ||
            [ "$arg2" = "record" ] ||
            [ "$arg2" = "listen" ]; }; then
            COMPREPLY=( `echo -n "$COMP_LINE" | dwc3 $arg1 audio_completion` )
        fi
    fi
}

__complete_dwc3_xhci()
{
    COMPREPLY=( `echo -n "$COMP_LINE" | dwc3-xhci completion` )
}

complete -F __complete_dwc2 dwc2
complete -F __complete_dwc3 dwc3
complete -F __complete_dwc3_xhci dwc3-xhci
