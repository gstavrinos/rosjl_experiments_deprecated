cmake_minimum_required(VERSION 2.8.3)
project(rosjl)

find_package(catkin REQUIRED COMPONENTS
    roscpp
    roslib
)

catkin_package(
  CATKIN_DEPENDS roscpp roslib
)


