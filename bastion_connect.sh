#!/bin/bash

# Check if KEY_PATH is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

# Check if at least 1 argument is given (bastion IP)
if [ -z "$1" ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

BASTION_IP="$1"
TARGET_IP="$2"
shift 2  # Shift so that $@ contains any additional command (if provided)

# If only bastion IP is given
if [ -z "$TARGET_IP" ]; then
    ssh -i "$KEY_PATH" -o "StrictHostKeyChecking=no" ubuntu@"$BASTION_IP"
else
    ssh -i "$KEY_PATH" -o "StrictHostKeyChecking=no" -o ProxyCommand="ssh -i $KEY_PATH -o StrictHostKeyChecking=no -W %h:%p ubuntu@$BASTION_IP" ubuntu@"$TARGET_IP" "$@"
fi

