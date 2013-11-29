#!/bin/sh

out="out.png"
showtype="filledcurve y1=0"
color="#1E90FF"
point="59"
tmpfile="tmpfile"
logfile=$LOGFILE

p_help(){
    echo "Usage: cpuplot [-h] [-o out_file_name] [-t type] [-c color] -n <60-600>"
    echo ""
    echo "  -h print the help."
    echo "  -o set the output file name. (default: out.png)"
    echo "  -t set the graph type. (one of 'filledcurve', 'lines'. default: 'filledcurve')"
    echo "  -c set graph color. (in hexadecimal form, default: #1E90FF)"
    echo "  -n set the number of point should use. (must be set. should be in range [60-600])"
}


plot(){

    # -r work on FreeBSD
    `tail -r -n $point ${logfile:="/tmp/sysmonitor"}  | awk '{print -NR " " $1}' > $tmpfile`


    echo "set title 'CPU Usage'
set xlabel 'time from now (sec)'
set ylabel 'CPU Usage (%)'
unset key
set grid front
set terminal png
set output '$out'
set yrange [0:100]
set xrange [-$point:0]
plot '$tmpfile' with $showtype linetype rgb '$color'
" | gnuplot

    if [ -f $tmpfile ]; then
        rm $tmpfile
    fi
}

while getopts ho:t:c:n: op
do
    case $op in
        h)
            p_help;
            exit 1
            ;;
        o)
            out=$OPTARG
            ;;
        t)
            showtype=$OPTARG

            if [ $showtype != "filledcurve" ] && [ $showtype != "lines" ]; then
                echo "file type error, it must be 'filledcurve' or 'lines'"
                echo ""
                p_help;
                exit 1
            fi

            if [ $showtype == "filledcurve" ]; then
                showtype="$showtype y1=0"
            fi
            ;;
        c)
            color=$OPTARG

            if [ `echo $color | grep -c "^#[0-9A-Fa-f]\{6\}$"` -eq "0" ] ; then

                echo "color format error, it must be a leading sharp '#' and 6 hex digits"
                echo ""
                p_help;
                exit 1
            fi
            ;;
        n)
            point=$OPTARG
            ;;
        *)
            ;;
    esac
done

if [ $point -lt 60 ] || [ $point -gt 600 ]; then
    echo "number error, it must be 60-600"
    echo ""
    p_help;
    exit 1
fi

plot;
