#!/usr/bin/bash
set -eu

mkdir -p "${TARGET}"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" \
    -P "${SSH_PORT}" \
    "${SSH_USERNAME}@${SSH_HOST}:/tmp/kubeadm/kubeadm_join" \
    "${TARGET}"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" \
    -P "${SSH_PORT}" \
    "${SSH_USERNAME}@${SSH_HOST}:/tmp/kubeadm/kubeadm_control_plane_join" \
    "${TARGET}"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" \
    -P "${SSH_PORT}" \
    "${SSH_USERNAME}@${SSH_HOST}:/tmp/kubeadm/kubeadm_config" \
    "${TARGET}"