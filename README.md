# AMD_Robotics_Hackathon_2025_[Project Name]

**Title:** AMD_Robotics_Hackathon_2025\-[Todo: Add mission2 task name]

**Team:** RoboTAI: Abdelrahman and Mohamed

---

## Summary

This repository contains our work for the AMD Robotics Hackathon 2025.

- **Mission 1:** We used the unified official task to complete a block pick and place task.

- **Mission 2:** We used the **so101 follower/leader arm** teleoperation data with three-cameras to collect data for the task **“[Todo: name the task]”** training dataset. 
  - We trained a policy on this dataset using LeRobot.
  - Then, we ran **inference** with the trained policy to **evaluate the performance** using the same hardware setup.
  - All training metadata and hyperparameters are captured in the **wandb latest-run directory** as required.

'

**Mission 1 Video of Performance:**


<div align="center">
  <img src="assets/mission1.gif" alt="description"/>
</div>


This task helped us familiarize with the LeRobot software stack and hardware (so-101 follower/leader) arm system. We have also tried to get this task done quickly to get insights into the whole stack of model training and inference. All the related requirements are included under the `mission1` directory. 

## Mission 1 Delivery URL

The following are our Hugging Face repo names:

- **Dataset URL**:
  - Training dataset:
    - `https://huggingface.co/datasets/abd64bit/record-red-block-test/tree/main`

- **Model URL**:
    - `https://huggingface.co/abd64bit/act_so101_redblock/tree/main`

___

Mission 2 Video of Performance

[Todo: Add video here]

The provided shell scripts under `mission2/code` focus on:

- Making hardware setup fast and reproducible (permissions, calibration).
- Standardizing data collection for Hugging Face datasets.
- Running inference with a three-camera setup for evaluation.

You can reproduce our data collection and inference runs by following the steps below.

---

## How To Reproduce Our Work

### Prerequisites

- AMD environment prepared as per Hackathon instructions (ROCm / GPU setup as applicable).
- `conda` environment with LeRobot installed (`lerobot`).
- so101 follower and leader arms connected via USB.
- At least three cameras connected for data recording.
- `v4l2-utils` installed (for camera inspection):
  
  ```
  sudo apt-get update
  sudo apt-get install -y v4l-utils
  ```

Make sure you know:

- Which `/dev/ttyACM*` corresponds to the follower and leader arms.
- Which `/dev/video*` indices correspond to the gripper, top, and side cameras.

You can inspect devices with:

```
ls /dev/ttyACM*
dmesg | grep tty
v4l2-ctl --list-devices
v4l2-ctl -d /dev/video6 --list-formats-ext # for video6
```

---

### 1. Repository Layout

Clone this repository and move into it:

```
git clone <YOUR_REPO_URL>.git
cd AMD_Robotics_Hackathon_2025_[Project Name]
```

Directory structure (template):

```
AMD_Robotics_Hackathon_2025_[Project Name]/
├── README.md
├── mission1
│   ├── code
│   │   ├── calib_follower.sh
│   │   ├── calib_leader.sh
│   │   ├── fix_arms_access_permission.sh
│   │   ├── login_huggingface.sh
│   │   ├── record_teleop_data_640x480_30fps_3cams.sh
│   │   └── inference_teleop_640x480_30fps_3cams.sh
│   └── wandb
│       └── <latest run directory copied from wandb of your Mission 1 training job>
└── mission2
    ├── code
    │   ├── calib_follower.sh
    │   ├── calib_leader.sh
    │   ├── fix_arms_access_permission.sh
    │   ├── login_huggingface.sh
    │   ├── record_teleop_data_640x480_30fps_3cams.sh
    │   └── inference_teleop_640x480_30fps_3cams.sh
    └── wandb
        └── <latest run directory copied from wandb of your Mission 2 training job>
```

[Todo: add the wandb files]

---

### 2. Hugging Face Authentication

Before using the scripts, configure your Hugging Face credentials in your shell, or `~/.bashrc`:

```
export HF_USER="your_hf_username"
export HUGGINGFACE_TOKEN="hf_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

Then run:

```
cd mission2/code
./login_huggingface.sh
```

The script `login_huggingface.sh` wraps:

- `huggingface-cli login --token "${HUGGINGFACE_TOKEN}" --add-to-git-credential`

**Note:** Do not hard-code tokens in the repo. Keep `HUGGINGFACE_TOKEN` and `HF_USER` in your shell configuration (`~/.bashrc`).

---

### 3. Fix Serial Access Permissions

The follower and leader arms appear as `/dev/ttyACM1` and `/dev/ttyACM0` respectively (update in the script if different on your system).

Script: `fix_arms_access_permission.sh`

```
#!/bin/bash
# Fix read/write permissions for both LeRobot serial devices (leader + follower arms)

# Serial ports (update if needed on different setups)
FOLLOWER_PORT="/dev/ttyACM1"
LEADER_PORT="/dev/ttyACM0"

# Fix permissions
sudo chmod a+rw ${FOLLOWER_PORT} && echo "follower_arm permission fixed on ${FOLLOWER_PORT}"
sudo chmod a+rw ${LEADER_PORT}   && echo "leader_arm permission fixed on ${LEADER_PORT}"
```

Run:

```
cd mission2/code
./fix_arms_access_permission.sh
```

---

### 4. Calibrate the Arms

Calibration scripts ensure both follower and leader arms are in a known state before recording data.

#### 4.1 Calibrate Follower

Script: `calib_follower.sh`

```
#!/bin/bash
# Ensure --robot.port matches the detected one

lerobot-calibrate \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM1 \
  --robot.id=follower_arm
```

Run:

```
./calib_follower.sh
```

#### 4.2 Calibrate Leader

Script: `calib_leader.sh`

```
#!/bin/bash
# Ensure --teleop.port matches the detected one

lerobot-calibrate \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM0 \
  --teleop.id=leader_arm
```

Run:

```
./calib_leader.sh
```

Again, change `/dev/ttyACM0` if the leader arm is on a different port.

---

### 5. Record Teleoperation Data (Mission 2 – Training Dataset)

We use a **three-camera setup** for recording teleoperation data for the task “Grab the duck”:

- `gripper` camera
- `top` camera
- `side` camera

Script: `record_teleop_data_640x480_30fps_3cams.sh`

Key points:

- Resolution: `640 x 480` at `30 fps` for all three cameras.
- Requires a **dataset name argument**, which becomes the final Hugging Face dataset repo name `${HF_USER}/${DATASET_NAME}`.
- Uses [Todo: decide] episodes with short episode and reset times, designed for efficient data collection.

Script content:

```
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
```

Run:

```
./record_teleop_data_640x480_30fps_3cams.sh drawer-opener-so101-v1
```

This will create/update the dataset:

- `https://huggingface.co/datasets/${HF_USER}/drawer-opener-so101-v1`

Adjust `CAM_GRIPPER`, `CAM_TOP`, `CAM_SIDE` if your `/dev/video*`devices (cameras) indices differ.

---

### 6. Train the Policy (Mission 2)

Training is done using LeRobot’s training pipeline. It uses:

- The dataset recorded in Step 5.
- A configuration corresponding to the task and network (ACT or other policy architecture [Todo: update this]).

The configuration, logs, and summaries are stored in the **wandb/latest-run** directory.

---

### 7. Run Inference For Evaluation

Once the policy is trained and uploaded to Hugging Face, we run inference using a similar three-camera teleop configuration.

Script: `inference_teleop_640x480_30fps_3cams.sh`

Key points:

- Uses 3 cameras (same indices as training, unless modified).
- Uses a fixed evaluation dataset name: `eval_drawer-opener-so101-v1`.
- Uses a model at `POLICY_PATH="${HF_USER}/act_drawer-opener-so101-v1"`. [Todo: update this]

Script content:

```
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
POLICY_PATH="${HF_USER}/act_drawer-opener-so101-v1"
DATASET_REPO="${HF_USER}/eval_drawer-opener-so101-v1"

lerobot-record \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM1 \
  --robot.id=follower_arm \
  --robot.cameras="{ gripper: {type: opencv, index_or_path: ${CAM_GRIPPER},  width: 640, height: 480, fps: 30}, \
                     top:     {type: opencv, index_or_path: ${CAM_TOP},      width: 640, height: 480, fps: 30}, \
                     side:    {type: opencv, index_or_path: ${CAM_SIDE},     width: 640, height: 480, fps: 30} }" \
  --teleop.type=so101_leader \
  --teleop.port=/dev/ttyACM0 \
  --teleop.id=leader_arm \
  --display_data=true \
  --dataset.repo_id=${DATASET_REPO} \
  --dataset.num_episodes=5 \
  --dataset.single_task="Evaluate grab the red block" \
  --dataset.push_to_hub=False \
  --dataset.episode_time_s=60 \
  --dataset.reset_time_s=5 \
  --policy.path=${POLICY_PATH}
```

Run:

```
./inference_teleop_640x480_30fps_3cams.sh
```

This will:

- Run inference using the policy hosted at `https://huggingface.co/${HF_USER}/act_drawer-opener-so101-v1`
- Record evaluation data into the dataset: `https://huggingface.co/datasets/${HF_USER}/eval_drawer-opener-so101-v1`

---

## Mission 2 Delivery URL [Todo: update this]

The following are our Hugging Face repo names:

- **Dataset URL**:
  - Training dataset: [Todo: update the URL]
    - `https://huggingface.co/datasets/${HF_USER}/record-duck-train-v1`

- **Model URL**:
  - Red block policy: [Todo: update the URL]
    - `https://huggingface.co/${HF_USER}/act_so101_redblock`

This README, together with the scripts and wandb directories, should provide all required information to understand, reproduce, and evaluate our Mission 2 work for the AMD Robotics Hackathon 2025.