# Dockerfile for voxblox
# Author: Dr. Johannes Graeter
# 
# In order to run rviz from the container install nvidia-docker2 (https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#supported-platforms)
# Build: sudo docker build --tag voxblox .
# Run: sudo docker run -it -v /path/to/my/data:/data --rm --privileged --net=host --env=NVIDIA_VISIBLE_DEVICES=all --env=NVIDIA_DRIVER_CAPABILITIES=all --env=DISPLAY --env=QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix --gpus 1 voxblox /bin/bash
# In the container:
# 1. Run $ source devel/setup.bash; tmux;
# Run the following in different terminals (make new terminal with ctrl+b,c switch between terminals with ctrl+b,n)
# 2. roscore
# 3. roslaunch voxblox_ros basement_dataset.launch bag_file:=/data/basement_dataset.bag
# 4. rviz (add voxblox mesh and choose tf frame "world")

FROM ros:melodic-perception

RUN sudo apt-get update && \
    sudo apt-get install -y python-wstool \
                            python-catkin-tools \
                            python-numpy \
                            ros-melodic-cmake-modules \
                            ros-melodic-tf \
                            ros-melodic-geometry \
                            ros-melodic-rviz \
                            protobuf-compiler \
                            libtool \
                            autoconf \
                            tmux \
                            vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/voxblox_user/catkin_ws/src && \
    cd /home/voxblox_user/catkin_ws && \
    catkin init && \
    catkin config --extend /opt/ros/melodic && \
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    catkin config --merge-devel 

#RUN mkdir -p /home/voxblox_user/catkin_ws/src/voxblox
#COPY . /home/voxblox_user/catkin_ws/src/voxblox/

WORKDIR /home/voxblox_user/catkin_ws/src/
RUN git clone https://github.com/johannes-graeter/voxblox.git
    wstool init . ./voxblox/voxblox_https.rosinstall && \
    wstool update

WORKDIR /home/voxblox_user/catkin_ws
RUN catkin build voxblox_ros
