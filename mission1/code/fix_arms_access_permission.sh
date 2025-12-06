#!/bin/bash
# Fix read/write permissions for both LeRobot serial devices (leader + follower arms)

# Serial ports (update if needed on different setups)
FOLLOWER_PORT="/dev/ttyACM1"
LEADER_PORT="/dev/ttyACM0"

# Fix permissions
sudo chmod a+rw ${FOLLOWER_PORT} && echo "follower_arm permission fixed on ${FOLLOWER_PORT}"
sudo chmod a+rw ${LEADER_PORT}   && echo "leader_arm permission fixed on ${LEADER_PORT}"