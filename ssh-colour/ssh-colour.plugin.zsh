DEBUG=0 #0 = off; 1 = on
MINRGB=17
MAXRGB=100

replace() {
    if [[ "${1[1,3]}" = "ssh" ]]; then
        dbg "SSH command was found!"
        starthost=-1
        endhost=-1
        for i in {3..${#1}}; do
            if [[ ${1[$i,$i]} = "@" && $starthost -lt 0 ]]; then
                starthost=$i+1
            fi
            if [[ ${1[$i,$i]} = " " && $endhost -lt 0 && starthost -gt 0 ]]; then
                endhost=$i
            fi
        done
        machinename=${1[$starthost,$endhost]}

        #translate ip to hostname.
        if [[ "${machinename[1,10]}" = "192.168.0." && $ADDIPADRESSPROFILE -eq 0 ]]; then
            dbg "$machinename is an ip adress. trying to translate it to the hostname."
            machinename=$(getent hosts $machinename | cut -d' ' -f4)
            dbg "Found the machinename to be $machinename."
        else
        fi

        #Lookup if Profile exists in config
        dbg "searching for $machinename in config file"
        if [[ $DEBUG -eq 1 ]]; then
            grep -n $machinename ~/.config/terminator/config
        else
            grep -n $machinename ~/.config/terminator/config > /dev/null
        fi
    
        #Creating new profile
        if [[ $? -eq 1 ]]; then
            dbg "Profile for host $machinename not found, creating a new profile."
            #Generate a random Colour
            randr=$[ $RANDOM % $MAXRGB + $MINRGB ]
            hexr=$(([##16]randr))
            randg=$[ $RANDOM % $MAXRGB + $MINRGB ]
            hexg=$(([##16]randg))
            randb=$[ $RANDOM % $MAXRGB + $MINRGB ]
            hexb=$(([##16]randb))
            newcolour=$hexr$hexg$hexb
            dbg "New colour for $machinename #$newcolour."

            #Generating and writing new Profile to config
            line1="\ \ [[$machinename]]"
            line2="\ \ \ \ background_color = \"#$newcolour\""
            line3="\ \ \ \ cursor_shape = ibeam"
            line4="\ \ \ \ cursor_color = \"#aaaaaa\""
            line5="\ \ \ \ foreground_color = \"#ffffff\""
            line6="\ \ \ \ scrollback_lines = 1000"
            dbg $line1
            dbg $line2
            dbg $line3
            dbg $line4
            dbg $line5
            dbg $line6
            sed -i "11i $line6" ~/.config/terminator/config
            sed -i "11i $line5" ~/.config/terminator/config
            sed -i "11i $line4" ~/.config/terminator/config
            sed -i "11i $line3" ~/.config/terminator/config
            sed -i "11i $line2" ~/.config/terminator/config
            sed -i "11i $line1" ~/.config/terminator/config
        else
            dbg "Profile for host $machinename was found."
        fi
    else
    fi
}

#Debug if variable is set
dbg() {
    if [[ $DEBUG -eq 1 ]]; then
        echo $1
    else
    fi
}

preexec_functions+=(replace)
