# xalts-test

This is a simple project with a simple rest API that can be deployed using the available terraform template by executing the following commands

Clone the entire repository and follow the given instructions

To see the plan and the list of resources getting created in Azure 
$$$ terraform plan 

To create resources 
$$$ terraform apply -auto-approve

Once the resources get created login to the virtual machine and copy the files that are present in the Docker folder 

Changing the permission of the shell script
$$$ chmod +x test.sh

To view the application's output in the localhost
$$$ curl localhost:5000/health

To view the application's output from external machine hit the below URL in the browser


http://<public_ip>:5000/health



