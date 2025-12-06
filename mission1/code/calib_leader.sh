#!/bin/bash
# Ensure --robot.port matches the detected one

lerobot-calibrate \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM0 \  # Update if different
  --teleop.id=leader_arm