#!/bin/bash
# Inference teleop run with 3 cameras: gripper + top + side.

# To find camera indices:
#   v4l2-ctl --list-devices
#   v4l2-ctl -d /dev/video6 --list-formats-ext

# Hugging Face config should be exported before using:
#   export HF_USER="your_username"
#   export HUGGINGFACE_TOKEN="hf_XXXXXXXXXXXXXXXX"

# Camera indices (update per machine)
CAM_GRIPPER=6
CAM_TOP=4
CAM_SIDE=8

# Updated evaluation model + dataset name
POLICY_PATH="${HF_USER}/act_so101_redblock"
DATASET_REPO="${HF_USER}/eval_record-red-block-test"

lerobot-record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM1 \  # follower arm — update if ACM changes
  --robot.id=follower_arm \
  --robot.cameras="{ gripper: {type: opencv, index_or_path: ${CAM_GRIPPER},  width: 640, height: 480, fps: 30}, \
                     top:     {type: opencv, index_or_path: ${CAM_TOP},      width: 640, height: 480, fps: 30}, \
                     side:    {type: opencv, index_or_path: ${CAM_SIDE},     width: 640, height: 480, fps: 30} }" \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM0 \  # leader arm — update if ACM changes
  --teleop.id=leader_arm \
  --display_data=true \
  --dataset.repo_id=${DATASET_REPO} \
  --dataset.num_episodes=5 \
  --dataset.single_task="Evaluate grab the red block" \
  --dataset.push_to_hub=False \
  --dataset.episode_time_s=60 \
  --dataset.reset_time_s=5 \
  --policy.path=${POLICY_PATH}
