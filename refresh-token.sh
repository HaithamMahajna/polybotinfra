#!/bin/bash
# Generate a new kubeadm join command with 24h TTL
JOIN_CMD=$(sudo kubeadm token create --ttl 24h --print-join-command)

# Save the join command to AWS Secrets Manager
aws secretsmanager put-secret-value \
  --secret-id kubeadm-join-command \
  --secret-string "$JOIN_CMD" \
  --region us-east-1
