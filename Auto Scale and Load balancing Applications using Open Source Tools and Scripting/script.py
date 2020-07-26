import psutil
import os
import subprocess
import time
import docker
client = docker.from_env()

#print("stress-ng -c 4 -l 40 --timeout 30s")
#print(psutil.cpu_percent(interval=4))
#temp = subprocess.Popen(["echo","abc","|","sudo","-S","/etc/init.d/haproxy","restart"], stdout = subprocess.PIPE)
#output = str(temp.communicate())
#print(output)



def writeServersToHaproxyFile(ip_addrs):
	f = open("/etc/haproxy/haproxy.cfg","w+")
	f.write("frontend myfrontserver\n\tbind 0.0.0.0:4000\n\ttimeout client 60s\n\tdefault_backend mybackserver\n")
	f.write("backend mybackserver\n\tbalance roundrobin\n\ttimeout connect 10s\n\ttimeout server 100s\n")
	ind=1
	for i in ip_addrs:
		f.write("\tserver a"+str(ind)+" "+str(i)+":5000\n")
		ind+=1

instance_now=0
docker_application=[]
container_name=[]
name_next=1
portNo=9050
while True:
	time.sleep(2)
	cpu_util=psutil.cpu_percent(interval=6)
	new_instances=int(cpu_util/10)
	
	if int(cpu_util/10)<1:
		new_instances=1
	print("New Instances",new_instances)
	print("Old Instances",instance_now)
	print("CPU Utilization",cpu_util)
	if instance_now!=new_instances:
		difference=instance_now-new_instances
		if difference<0:		
			#Add Instances
			print("\tAdd ",difference," insts")
			difference=-difference
			i=1
			while i<=difference:
				cont=client.containers.run('flaskappdemo',name="a"+str(name_next),ports={'5000/tcp':str(portNo)},detach=True)
				print("\t\tCreated Containers ",cont)
				container_name.append("a"+str(name_next))
				docker_application.append(cont)
				name_next+=1
				portNo+=1
				i+=1
			

		elif difference>0:
			#Remove Instances	
			print("\tRem ",difference," insts")
			i=1
			while i<=difference:
				rem_cont=docker_application.pop()
				print("\t\tRemoving Containers ",rem_cont)
				rem_cont.stop()
				rem_cont.remove()
				name_next-=1
				portNo-=1
				container_name.pop()
				i+=1
		ip_addresses=[]
		for cont in container_name:
			container = client.containers.get(cont)
			ip_add = container.attrs['NetworkSettings']['IPAddress']
			ip_addresses.append(ip_add)
		writeServersToHaproxyFile(ip_addresses)

		os.system("echo 'YOUR_LINUX_PASSWORD' | sudo -S /etc/init.d/haproxy restart")
		print("Ip-Addresses",ip_addresses)
		print("Docker Containers",docker_application)
		print("Docker Containers Name",container_name)
		print("\n\n")
		time.sleep(40)
		instance_now=new_instances
		

#docker run -it -p 5000:5000  flaskapp
#killall haproxy
#docker build -t flaskapp:latest .
