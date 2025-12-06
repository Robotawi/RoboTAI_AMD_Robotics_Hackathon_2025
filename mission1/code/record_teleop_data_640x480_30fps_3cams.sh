#!/bin/bash

# Requires passing dataset name:
# Example: ./record_teleop_data_640x480_30fps_3cams.sh cube-pickup-dataset-v1

# To find camera indices:
#   v4l2-ctl --list-devices
#   v4l2-ctl -d /dev/video6 --list-formats-ext

# Hugging Face config should be exported before using:
#   export HF_USER="your_username"
#   export HUGGINGFACE_TOKEN="hf_XXXXXXXXXXXXXXXX"

CAM_GRIPPER=6
CAM_TOP=4
CAM_SIDE=8

DATASET_NAME=$1

if [ -z "$DATASET_NAME" ]; then
    echo "Please provide a dataset name"
    echo "Example: ./record_teleop_data_640x480_30fps_3cams.sh cube-pickup-dataset-v1"
    exit 1
fi

lerobot-record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM1 \
  --robot.id=follower_arm \
  --robot.cameras="{ gripper: {type: opencv, index_or_path: ${CAM_GRIPPER}, width: 640, height: 480, fps: 30}, \
                     top:     {type: opencv, index_or_path: ${CAM_TOP}, width: 640, height: 480, fps: 30}, \
                     side:    {type: opencv, index_or_path: ${CAM_SIDE}, width: 640, height: 480, fps: 30} }" \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM0 \
  --teleop.id=leader_arm \
  --display_data=true \
  --dataset.repo_id="${HF_USER}/${DATASET_NAME}" \
  --dataset.num_episodes=10 \
  --dataset.single_task="Grab the duck" \
  --dataset.push_to_hub=False \
  --dataset.episode_time_s=13 \
  --dataset.reset_time_s=0 \
  --resume=False

