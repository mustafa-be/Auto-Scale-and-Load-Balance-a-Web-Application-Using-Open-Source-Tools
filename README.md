# Auto Scale and Load-Balance a Web Application
## Auto Scale and Load balancing Applications using Open Source Tools and Scripting
This is a basic demonstration of creating a dockerimage of a simple flask application and then load balancing the launched images using haproxy service which is a open source load balancing tool. The files contain a python script that constantly monitors the cpu utilization and calculates the no of docker image instances to be running (as a way of demonstration of increased load and the needs for new instances to be up ie. autoscaling). The number of application dockers N up is calculated as N=int(cpu_util/10). Stress can be generated using the ubunto stress tool. Everytime new inistances are created they are added to the haproxy file and then the haproxy service is restarted.
This project was run and tested on Ubuntu.

### How to run
- Install python, dockersdk for python, docker, haproxy, psutil to your ubuntu machine.
- Build a docker image of the docker file using the following command .. docker build -t flaskapp:latest ..
- Run the pyhon script.py (add your linux password to line 77 on the script).



## Auto Scale and Load balancing Application on AWS EC2 using Terraform
Terraform is an open-source infrastructure as code software tool created by HashiCorp. It enables users to define and provision a datacenter infrastructure using a high-level configuration language. This folder contains a .tf file contains code for deploying infrastructure on AWS EC2. The following terraform files are used achieve the following tasks.
- Creates  public subnets ps-1 and ps2 and private subnets prs-1 and prs-2.
- Creates a Launch template and its security group and key pair.
- Creates a nat instance(ter-nat-instance) and route table and associated it with private subnets.
- Added a route for 0.0.0.0/0 destination target is nat-instance (ter-nat-instance) as created above.
- Creates an autoscaling group, target group, loadbalancer.
- Associates load balancer to target group via resource "aws_lb_listener" and associated autoscaling group with target group via resource "aws_autoscaling_attachment".

### How to run
- Install terraform on your machine.
- Run terraform plan with the directory that contains .tf file.
- Download your AWS credentials file and add its path to the .tf file.
- Create a key pair on AWS EC2 console and export its .pub file to the directory that contains .tf file.
- Add your vpc id to your .tf file where "YOUR_VPC_ID" is created.
- Run terraform apply with the directory that contains .tf file.
