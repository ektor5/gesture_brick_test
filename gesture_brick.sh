#!/bin/bash
#
# UDOO Gesture Brick
# Simple test script
#
# based on https://github.com/Seeed-Studio/Gesture_PAJ7620
# Copyright (c) 2015 seeed technology inc.
# Website    : www.seeed.cc
#
# Ek5 @ 2016/05
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

I2C_BUS=1
QUIET=0
PAJ7620_ADDR_BASE=0x00
PAJ7620_REGISTER_BANK_SEL=$((PAJ7620_ADDR_BASE + 0xEF))
PAJ7620_ID=0x73
PAJ7620_BANK0=0x00
PAJ7620_GESTURE=0x43
PAJ7620_WAVE=0x44

GES_RIGHT_FLAG=$((1<<0))
GES_LEFT_FLAG=$((1<<1))
GES_UP_FLAG=$((1<<2))
GES_DOWN_FLAG=$((1<<3))
GES_FORWARD_FLAG=$((1<<4))
GES_BACKWARD_FLAG=$((1<<5))
GES_CLOCKWISE_FLAG=$((1<<6))
GES_COUNT_CLOCKWISE_FLAG=$((1<<7))
GES_WAVE_FLAG=$((1<<0))

GES_REACTION_TIME=500    # You can adjust the reaction time according to the actual circumstance.
GES_ENTRY_TIME=800       # When you want to recognize the Forward/Backward
                         # gestures, your gestures' reaction time must less than
                         # GES_ENTRY_TIME(0.8s).
GES_QUIT_TIME=1000

initRegisterArray=(
  {0xEF,0x00}
  {0x32,0x29}
  {0x33,0x01}
  {0x34,0x00}
  {0x35,0x01}
  {0x36,0x00}
  {0x37,0x07}
  {0x38,0x17}
  {0x39,0x06}
  {0x3A,0x12}
  {0x3F,0x00}
  {0x40,0x02}
  {0x41,0xFF}
  {0x42,0x01}
  {0x46,0x2D}
  {0x47,0x0F}
  {0x48,0x3C}
  {0x49,0x00}
  {0x4A,0x1E}
  {0x4B,0x00}
  {0x4C,0x20}
  {0x4D,0x00}
  {0x4E,0x1A}
  {0x4F,0x14}
  {0x50,0x00}
  {0x51,0x10}
  {0x52,0x00}
  {0x5C,0x02}
  {0x5D,0x00}
  {0x5E,0x10}
  {0x5F,0x3F}
  {0x60,0x27}
  {0x61,0x28}
  {0x62,0x00}
  {0x63,0x03}
  {0x64,0xF7}
  {0x65,0x03}
  {0x66,0xD9}
  {0x67,0x03}
  {0x68,0x01}
  {0x69,0xC8}
  {0x6A,0x40}
  {0x6D,0x04}
  {0x6E,0x00}
  {0x6F,0x00}
  {0x70,0x80}
  {0x71,0x00}
  {0x72,0x00}
  {0x73,0x00}
  {0x74,0xF0}
  {0x75,0x00}
  {0x80,0x42}
  {0x81,0x44}
  {0x82,0x04}
  {0x83,0x20}
  {0x84,0x20}
  {0x85,0x00}
  {0x86,0x10}
  {0x87,0x00}
  {0x88,0x05}
  {0x89,0x18}
  {0x8A,0x10}
  {0x8B,0x01}
  {0x8C,0x37}
  {0x8D,0x00}
  {0x8E,0xF0}
  {0x8F,0x81}
  {0x90,0x06}
  {0x91,0x06}
  {0x92,0x1E}
  {0x93,0x0D}
  {0x94,0x0A}
  {0x95,0x0A}
  {0x96,0x0C}
  {0x97,0x05}
  {0x98,0x0A}
  {0x99,0x41}
  {0x9A,0x14}
  {0x9B,0x0A}
  {0x9C,0x3F}
  {0x9D,0x33}
  {0x9E,0xAE}
  {0x9F,0xF9}
  {0xA0,0x48}
  {0xA1,0x13}
  {0xA2,0x10}
  {0xA3,0x08}
  {0xA4,0x30}
  {0xA5,0x19}
  {0xA6,0x10}
  {0xA7,0x08}
  {0xA8,0x24}
  {0xA9,0x04}
  {0xAA,0x1E}
  {0xAB,0x1E}
  {0xCC,0x19}
  {0xCD,0x0B}
  {0xCE,0x13}
  {0xCF,0x64}
  {0xD0,0x21}
  {0xD1,0x0F}
  {0xD2,0x88}
  {0xE0,0x01}
  {0xE1,0x04}
  {0xE2,0x41}
  {0xE3,0xD6}
  {0xE4,0x00}
  {0xE5,0x0C}
  {0xE6,0x0A}
  {0xE7,0x00}
  {0xE8,0x00}
  {0xE9,0x00}
  {0xEE,0x07}
  {0xEF,0x01}
  {0x00,0x1E}
  {0x01,0x1E}
  {0x02,0x0F}
  {0x03,0x10}
  {0x04,0x02}
  {0x05,0x00}
  {0x06,0xB0}
  {0x07,0x04}
  {0x08,0x0D}
  {0x09,0x0E}
  {0x0A,0x9C}
  {0x0B,0x04}
  {0x0C,0x05}
  {0x0D,0x0F}
  {0x0E,0x02}
  {0x0F,0x12}
  {0x10,0x02}
  {0x11,0x02}
  {0x12,0x00}
  {0x13,0x01}
  {0x14,0x05}
  {0x15,0x07}
  {0x16,0x05}
  {0x17,0x07}
  {0x18,0x01}
  {0x19,0x04}
  {0x1A,0x05}
  {0x1B,0x0C}
  {0x1C,0x2A}
  {0x1D,0x01}
  {0x1E,0x00}
  {0x21,0x00}
  {0x22,0x00}
  {0x23,0x00}
  {0x25,0x01}
  {0x26,0x00}
  {0x27,0x39}
  {0x28,0x7F}
  {0x29,0x08}
  {0x30,0x03}
  {0x31,0x00}
  {0x32,0x1A}
  {0x33,0x1A}
  {0x34,0x07}
  {0x35,0x07}
  {0x36,0x01}
  {0x37,0xFF}
  {0x38,0x36}
  {0x39,0x07}
  {0x3A,0x00}
  {0x3E,0xFF}
  {0x3F,0x00}
  {0x40,0x77}
  {0x41,0x40}
  {0x42,0x00}
  {0x43,0x30}
  {0x44,0xA0}
  {0x45,0x5C}
  {0x46,0x00}
  {0x47,0x00}
  {0x48,0x58}
  {0x4A,0x1E}
  {0x4B,0x1E}
  {0x4C,0x00}
  {0x4D,0x00}
  {0x4E,0xA0}
  {0x4F,0x80}
  {0x50,0x00}
  {0x51,0x00}
  {0x52,0x00}
  {0x53,0x00}
  {0x54,0x00}
  {0x57,0x80}
  {0x59,0x10}
  {0x5A,0x08}
  {0x5B,0x94}
  {0x5C,0xE8}
  {0x5D,0x08}
  {0x5E,0x3D}
  {0x5F,0x99}
  {0x60,0x45}
  {0x61,0x40}
  {0x63,0x2D}
  {0x64,0x02}
  {0x65,0x96}
  {0x66,0x00}
  {0x67,0x97}
  {0x68,0x01}
  {0x69,0xCD}
  {0x6A,0x01}
  {0x6B,0xB0}
  {0x6C,0x04}
  {0x6D,0x2C}
  {0x6E,0x01}
  {0x6F,0x32}
  {0x71,0x00}
  {0x72,0x01}
  {0x73,0x35}
  {0x74,0x00}
  {0x75,0x33}
  {0x76,0x31}
  {0x77,0x01}
  {0x7C,0x84}
  {0x7D,0x03}
  {0x7E,0x01}
)

GREEN="\e[32m"
RED="\e[31m"
BOLD="\e[1m"
RST="\e[0m"

log() {
  # args: string
  local COLOR=${GREEN}${BOLD}  
  local MOD="-e"

  case $1 in
    err) COLOR=${RED}${BOLD}
      shift ;;
    pre) MOD+="n" 
      shift ;;
    fat) COLOR=${RED}${BOLD}
      shift ;;
    *) ;;
  esac

  (( QUIET )) || echo $MOD ${COLOR}$@${RST}

}

error() {
  #error($E_TEXT,$E_CODE)

  local E_TEXT=$1
  local E_CODE=$2

  [[ -z $E_CODE ]] && E_CODE=1
  [[ -z $E_TEXT ]] || log err "$E_TEXT"

  exit $E_CODE
}

usage() {
  cat <<-USAGE
		Usage: ./gesture_brick.sh [-q]
		Options:

		    -q     Quiet, suppress initialization output
		    -h     Display usage
		
		USAGE
}
usagee(){
  usage
  exit ${1:-1}
}

_set(){
  i2cset -f -y $I2C_BUS $PAJ7620_ID $1 $2 || ( log err "Cannot set i2c register" && false )
}
_get(){
  i2cget -f -y $I2C_BUS $PAJ7620_ID $1 || ( log err "Cannot get i2c register" && false )
}

while getopts ":qh" option
do
  case $option in
    q) _QUIET=1 ;;
    h) usage; exit ;;
    *) log err "Option not recognized" ; usagee; exit ;;
  esac
done

(( _QUIET )) && QUIET=1

# set to active mode
log "Initializing..."
_set $PAJ7620_REGISTER_BANK_SEL $PAJ7620_BANK0 || error "Cannot set BANK0"
_set $PAJ7620_REGISTER_BANK_SEL $PAJ7620_BANK0 || error "Cannot set BANK0 a second time"

#get addresses
log pre "Get addresses... "
addr[0]=$(_get 0x00)
addr[1]=$(_get 0x01)

log "addr0: ${addr[0]} addr1: ${addr[1]}"

if (( ( ${addr[0]} != 0x20 ) || ( ${addr[1]} != 0x76 ) ))
then
  error "Error: data not valid"

elif (( ${addr[0]} == 0x20 ))
then
  log "Wake-up finish"

fi

log "Resetting registers..."
#reset regs
for i in ${!initRegisterArray[*]}
do
  if (( $i % 2 ))
  then continue
  fi

  _addr=${initRegisterArray[$i]}
  _data=${initRegisterArray[$((i+1))]}

  _set $_addr $_data ||
    error "cannot reset register $_addr to $_data"

done

_set $PAJ7620_REGISTER_BANK_SEL $PAJ7620_BANK0 ||
  error "cannot set BANK0 a second time"

log "Initialization done"
log "Start!"

while [ 1 ]
do
  data=$(_get $PAJ7620_GESTURE)

  #echo $data $(( data ))

  case $(( data )) in
    # When different gestures be detected, the variable 'data' will be set to
    # different values by paj7620ReadReg(0x43, 1, &data).

    $GES_RIGHT_FLAG)
    sleep 0.$GES_ENTRY_TIME
    data=$(_get $PAJ7620_GESTURE)

    if ((data == GES_FORWARD_FLAG))
    then
      echo "Forward"
      sleep 0.$GES_QUIT_TIME

    elif ((data == GES_BACKWARD_FLAG))
    then
      echo "Backward"
      sleep 0.$GES_QUIT_TIME

    else
      echo "Right"

    fi
    ;;

  $GES_LEFT_FLAG)
    sleep 0.$GES_ENTRY_TIME
    data=$(_get $PAJ7620_GESTURE)

    if ((data == GES_FORWARD_FLAG))
    then
      echo "Forward"
      sleep 0.$GES_QUIT_TIME

    elif ((data == GES_BACKWARD_FLAG))
    then
      echo "Backward"
      sleep 0.$GES_QUIT_TIME

    else
      echo "Left"

    fi
    ;;

  $GES_UP_FLAG)
    sleep 0.$GES_ENTRY_TIME
    data=$(_get $PAJ7620_GESTURE)

    if ((data == GES_FORWARD_FLAG))
    then
      echo "Forward"
      sleep 0.$GES_QUIT_TIME

    elif ((data == GES_BACKWARD_FLAG))
    then
      echo "Backward"
      sleep 0.$GES_QUIT_TIME

    else
      echo "Up"
    fi
    ;;

  $GES_DOWN_FLAG)
    sleep 0.$GES_ENTRY_TIME
    data=$(_get $PAJ7620_GESTURE)

    if ((data == GES_FORWARD_FLAG))
    then
      echo "Forward"
      sleep 0.$GES_QUIT_TIME

    elif ((data == GES_BACKWARD_FLAG))
    then
      echo "Backward"
      sleep 0.$GES_QUIT_TIME

    else
      echo "Down"

    fi
    ;;

  $GES_FORWARD_FLAG)
    echo "Forward"
    sleep 0.$GES_QUIT_TIME
    ;;

  $GES_BACKWARD_FLAG)
    echo "Backward"
    sleep 0.$GES_QUIT_TIME
    ;;
  $GES_CLOCKWISE_FLAG)
    echo "Clockwise"
    ;;
  $GES_COUNT_CLOCKWISE_FLAG)
    echo "Anti-clockwise"
    ;;
  *)
    data=$(_get $PAJ7620_WAVE)

    if ((data == GES_WAVE_FLAG))
    then
      echo "Wave"
    fi
    ;;

  esac

  sleep 0.1
done
