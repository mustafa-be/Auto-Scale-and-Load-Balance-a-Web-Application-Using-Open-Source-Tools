# Auto Scale and Load-Balance a Web Application
## Introduction
### Auto Scale and Load balancing Applications using Open Source Tools and Scripting
This is a basic demonstration of creating a dockerimage of a simple flask application and then load balancing the launched images using haproxy service which is a open source load balancing tool. The files contain a python script that constantly monitors the cpu utilization and calculates the no of docker image instances to be running (as a way of demonstration of increased load and the needs for new instances to be up ie. autoscaling). The number of application dockers N up is calculated as N=int(cpu_util/10). Stress can be generated using the ubunto stress tool.
This project was run and tested on Ubuntu.


### Auto Scale and Load balancing Application on AWS EC2 using Terraform
