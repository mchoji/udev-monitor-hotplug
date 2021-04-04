#!/bin/bash

# Adapt this script to your needs. Really. This shouldn't work out of the box.

# define your layouts here
# the commands for the functions below can be found/adjusted from "xlayoutdisplay"
# (https://github.com/alex-courtis/xlayoutdisplay)

# layout: external 4k monitor to the left of laptop
layout_ext_left() {
	xrandr \
		--dpi 144 \
		--output HDMI-1-0 --mode 3840x2160 --rate 30 --pos 0x0 \
		--output eDP-1 --mode 1920x1080 --rate 30 --pos 3840x0 --primary \
		--output DP-1 --off
	echo "Xft.dpi: 144" | xrdb -merge""
}

# layout: external 4k monitor to the right of laptop
layout_ext_right() {
	xrandr \
		--dpi 144 \
		--output eDP-1 --mode 1920x1080 --rate 30 --pos 0x0 --primary \
		--output HDMI-1-0 --mode 3840x2160 --rate 30 --pos 1920x0 \
		--output DP-1 --off
	echo "Xft.dpi: 144" | xrdb -merge""
}

# layout: default (only laptop monitor)
layout_default() {
	xrandr \
		--dpi 96 \
		--output eDP-1 --mode 1920x1080 --rate 60 --pos 0x0 --primary \
		--output HDMI-1-0 --off \
		--output DP-1 --off
	echo "Xft.dpi: 96" | xrdb -merge""
}
# end of layouts declaration

DEVICES=$(find /sys/class/drm/*/status)

#inspired by /etc/acpd/lid.sh and the function it sources

displaynum=`ls /tmp/.X11-unix/* | sed s#/tmp/.X11-unix/X##`
display=":$displaynum.0"
export DISPLAY=":$displaynum.0"

# from https://wiki.archlinux.org/index.php/Acpid#Laptop_Monitor_Power_Off
export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')

# this while loop declares $HDMI1 $eDP1 and others if they are plugged in
while read l; do
	dir=$(dirname $l)
	status=$(cat $l)
	dev=$(echo $dir | cut -d\- -f 2-)

	if [ $(expr match  $dev "HDMI") != "0" ]; then
		# remove the -X- part from "HDMI-X-n"
		dev=HDMI${dev#HDMI-?-}
	else
		dev=$(echo $dev | tr -d '-')
	fi

	if [ "$status" == "connected" ]; then
		echo $dev "connected"
		declare $dev="yes"
	fi
done <<< "$DEVICES"

# this part probably have to be adapted to your needs
# variable names will not contain hifens
if [ -n "$HDMI1" ]; then
	echo "HDMI1 is plugged in"
	layout_ext_left
elif [ -z "$HDMI1" ]; then
	echo "No external monitors are plugged in"
	layout_default
fi
