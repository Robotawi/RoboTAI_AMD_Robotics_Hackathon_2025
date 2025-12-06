#!/bin/bash

# WARNING: Do NOT hard-code tokens inside a repo!
# Recommendation: store in: ~/.bashrc
# export HUGGINGFACE_TOKEN="hf_XXXX.."
# export HF_USER="username"

huggingface-cli login --token "${HUGGINGFACE_TOKEN}" --add-to-git-credential
