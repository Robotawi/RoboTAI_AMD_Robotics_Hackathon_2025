# AMD Robotics Hackathon 2025: Drawer Opener with Object Placement


**Team: 41** (RoboTAI) - Abdelrahman Abubakr and Mohamed Raessa

---

## Summary

This repository contains our work for the AMD Robotics Hackathon 2025.

## Mission 1

We used the unified official task to complete a block pick and place task. The following videos shows the robot performance during mission 1.


<div align="center">
  <img src="assets/mission1.gif" alt="description"/>
</div>


This task helped us familiarize with the LeRobot software stack and hardware (so-101 follower/leader) arm system. We have also tried to get this task done quickly to get insights into the whole stack of model training and inference. All the related requirements are included under the `mission1` directory. 

#### Mission 1 Delivery URLs

The following are our Hugging Face repo names:

- **Dataset URL**: [https://huggingface.co/datasets/abd64bit/record-red-block-test](https://huggingface.co/datasets/abd64bit/record-red-block-test)

- **Model URL**: [https://huggingface.co/abd64bit/act_so101_redblock](https://huggingface.co/abd64bit/act_so101_redblock)


## Mission 2


This project solves a practical and challenging real-world manipulation task:  
**Autonomously opening a drawer, picking an object, placing it inside a drawer, and closing the drawer**

This requires precise control of articulated objects and robust sequencing of multiple sub-tasks with sensor-based feedback.

We collected multi-view teleoperation data using the SO-101 system and trained an ACT (Action Chunking with Transformers) policy via LeRobot.


## Submission Details

### 1. Mission Description

Real-world motivation: Drawer manipulation combined with object pick and place is commonly required in assistive robots, household robots, and storage automation — yet difficult due to combined **manipulation + grasping + spatial awareness** requirements.

Our robot autonomously completes the full pipeline:

1. Reach & grasp drawer handle.
2. Open the drawer.
3. Pick an object (fluffy duck toy).  
4. Place it inside drawer.
5. Close the drawer.

With years of experience building classical algorithmic systems for manipulation and grasping, this project represents a meaningful shift toward learning-based approaches.

### 2. Creativity

- We teleoperated the SO-101 robot **in its highest manipulability regions**, producing:
  - Smooth trajectories (minimal kinematic strain).
  - Natural hand-object interaction for grasping.
  - Relatively simple data collection with fewer failed demonstrations.
- **3-camera synchronized multi-view dataset**:
  - **Gripper view**: fine manipulation + grasp interaction
  - **Top view**: drawer motion + global workspace state
  - **Side view**: depth perspective + collision safety
- **Disturbance-Resilient Performance**  
  The learned model is **phase-aware**.  
  If interrupted, for example: drawer reopened after object placement, it autonomously recognizes the state and closes the drawer.
  
-   We selected the ACT model because it directly learns  
  multi-stage behavior and dynamic recovery from real data


### 3. Technical implementations

#### **Training**


- Policy: **ACT (Action Chunking with Transformers)** from LeRobot

- Inputs: Multi-view image streams + robot joint values

<div align="center">
  <img src="assets/0_training_data_collection.gif" alt="description"/>
</div>

#### **Teleoperation / Dataset capture**

  - Robot: SO-101 follower/leader arm  
  - Cameras: 3× USB, color, **640×480 @ 30 FPS**  

<div align="center">
  <img src="assets/dataset-capture.jpg" alt="description"/>
</div>

Scripts included in `mission2/code`:
- `fix_arms_access_permission.sh`
- `calib_follower.sh`
- `calib_leader.sh`
- `record_teleop_data_640x480_30fps_3cams.sh`


####  *Inference and Evaluation*

- Same real-world hardware setup.
- Fully autonomous execution after start signal.
- Recovers from disturbances and ambiguous drawer states.


#### 1. Successful Full-Task Execution

The robot completes open → pick → place → close reliably across multiple trials.

<div align="center">
  <img src="assets/1_mession2_demo_2x.gif" alt="description"/>
</div>

---

#### 2. Robust Phase Recovery 

If the drawer is disturbed after closing, the robot detects correct stage and resumes closing.

<div align="center">
  <img src="assets/2_middle_run_interruption_2x.gif" alt="description"/>
</div>

---

#### 3️3. Generalization to Lighting Conditions

Performance remains stable when switching to dim lighting conditions.

<div align="center">
  <img src="assets/3_robustness_to_environment_change_2x.gif" alt="description"/>
</div>

---

#### 4. Failure Handling & Retry Behavior

If the initial open attempt fails, the robot readjusts and retries until the sub-task is complete.

<div align="center">
  <img src="assets/4_runs_even_if_confused_2x.gif" alt="description"/>
</div>


## Ease of Use

- **Generalizable** to other objects if trained on them.
- **Flexible** dataset format (LeRobot standard)
- Easy execution:
  - Data collection: `./record_*.sh <dataset-name>`
  - Training: single LeRobot notebook also included.
  - Inference: `./inference_*.sh`

Supports future:
- Multi-drawer tasks  
- Multi-object placement  
- Adaptation to home or warehouse settings

## Mission 2 Delivery URLs

The following are our Hugging Face repo names:

- **Dataset URL**: [https://huggingface.co/datasets/abd64bit/drawer-opener-so101-v1](https://huggingface.co/datasets/abd64bit/drawer-opener-so101-v1)

- **Model URL**: [https://huggingface.co/abd64bit/drawer-opener-act-so101](https://huggingface.co/abd64bit/drawer-opener-act-so101)


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
- Uses 8 episodes with short episode and reset times, designed for efficient data collection.
- Collect 8 sets of episodes, adding up to a total 64 episodes in the training data.

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
- A configuration corresponding to the task and network (ACT policy).

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

his README, together with the scripts and wandb directories, should provide all required information to understand, reproduce, and evaluate our Mission 2 work for the AMD Robotics Hackathon 2025.