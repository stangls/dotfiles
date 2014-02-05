#!/bin/bash

# Mine
alias off='sudo poweroff'
alias reboot='sudo reboot'
alias hibernate='sudo pm-hibernate'

alias pd=pushd
alias pn="pushd +1 /dev/null"
alias ud=popd
alias d=dirs

alias devMiBaby='source /home/stefan/bin/devMiBaby.sh'
alias devMiBabyApp='source /home/stefan/bin/devMiBabyApp.sh'
alias devPferdeHeilpraxisNufer='source /home/stefan/bin/devPferdeHeilpraxisNufer.sh'

##### FROM http://aijazansari.com/2010/02/20/navigating-the-directory-stack-in-bash/
    # An enhanced 'cd' - push directories
    # onto a stack as you navigate to it.
    #
    # The current directory is at the top
    # of the stack.
    #
    function stack_cd {
        if [ "$1" ]; then
            # use the pushd bash command to push the directory
            # to the top of the stack, and enter that directory
            pushd "$1" > /dev/null
        else
            # the normal cd behavior is to enter $HOME if no
            # arguments are specified
            pushd $HOME > /dev/null
        fi
    }
    # the cd command is now an alias to the stack_cd function
    #
    alias cd=stack_cd
    # Swap the top two directories on the stack
    #
    function swap {
        pushd > /dev/null
    }
    # s is an alias to the swap function
    alias s=swap
    # Pop the top (current) directory off the stack
    # and move to the next directory
    #
    function pop_stack {
        popd > /dev/null
    }
    alias p=pop_stack
    # Display the stack of directories and prompt
    # the user for an entry.
    #
    # If the user enters 'p', pop the stack.
    # If the user enters a number, move that
    # directory to the top of the stack
    # If the user enters 'q', don't do anything.
    #
    function display_stack
    {
        dirs -v
        echo -n "#: "
        read dir
        if [[ $dir = 'p' ]]; then
            pushd > /dev/null
        elif [[ $dir != 'q' ]] && [[ $dir != '' ]]; then
            d=$(dirs -l +$dir);
            popd +$dir > /dev/null
            pushd "$d" > /dev/null
        fi
    }
    alias d=display_stack
