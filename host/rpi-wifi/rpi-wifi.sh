#!/bin/sh

BINARY_NAME=$0

function lecho() {
  echo -e "$@"
}

function error_lecho() {
  echo -e "$@" >&2
}

function usage() {
  error_lecho "$BINARY_NAME --rpi=<rpi ssh target> --ssid=<network ssid> [--password=<network password>] [--interface=<network interface>]"
  error_lecho "\t-r --rpi       RPi ssh target, e.g. pi2, pi@192.168.200.2"
  error_lecho "\t-s --ssid      SSID for target network"
  error_lecho "\t-p --password  Password for target network"
  error_lecho "\t-i --interface Network interface name. Default is wlan0."
}

GETOPT_COMMAND_STRUCTURE=`getopt -o r:s:p:i: --long rpi:,ssid:,password:,interface: -n 'rpi-wifi' -- "$@"`

if [ $# == 0 ]; then
  usage
  exit 1
fi

eval set -- "$GETOPT_COMMAND_STRUCTURE"

RPI=
SSID=
PASSWORD=
INTERFACE="wlan0"

while true; do
  case "$1" in
    -r | --rpi ) RPI="$2"; shift 2 ;;
    -s | --ssid ) SSID="$2"; shift 2 ;;
    -p | --password ) PASSWORD="$2"; shift 2 ;;
    -i | --interface ) INTERFACE="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ -z "$RPI" -o -z "$SSID" ]; then
  usage
  exit 1
fi

SSH_CHECK=`ssh $RPI exit 2>&1`
if [ ! -z "$SSH_CHECK" ]; then
  error_lecho "Unable to reach rpi: $RPI"
  usage
  exit 1
fi

IWCONFIG_OUTPUT="`ssh $RPI /sbin/iwconfig 2>&1`"
INTERFACE_CHECK="`echo $IWCONFIG_OUTPUT | grep $INTERFACE`"
if [ -z "$INTERFACE_CHECK" ]; then
  error_lecho "Invalid interface: $INTERFACE"
  error_lecho "Available interfaces..."
  error_lecho "$IWCONFIG_OUTPUT"
  usage
  exit 1
fi
