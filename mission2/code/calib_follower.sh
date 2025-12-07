#!/bin/bash
# Ensure --robot.port matches the detected one

lerobot-calibrate \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM1 \  # Update if different
  --robot.id=follower_arm