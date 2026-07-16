#!/usr/bin/env bash

# Start D-Bus if not running
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax)"
    export DBUS_SESSION_BUS_ADDRESS
fi

# Start gnome-keyring-daemon
eval "$(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)"
export SSH_AUTH_SOCK

