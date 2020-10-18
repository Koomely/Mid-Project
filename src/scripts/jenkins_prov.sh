while [ ! -f /home/ubuntu/Done ] ; do echo 'Waiting on User Data...'; sleep 3; done;
sleep 5;



cd /home/ubuntu/src/Jenkins_init/
sudo docker build -t jenkinsdev .

DOCKER_CONTAINER=$(docker run -d -p 8080:8080 jenkinsdev);

# checking if docker HTTP service is up

a=1
while [ $a -ne 0 ]; do echo "Container initializing..."; sleep 4; wget localhost:8080 > /dev/null 2>&1; a=$?;  done 

echo "Docker container running. ID : $DOCKER_CONTAINER"
echo "Inserting SSH Key Credentials"
docker exec -ti $DOCKER_CONTAINER sh -c "wget http://localhost:8080/jnlpJars/jenkins-cli.jar; java -jar jenkins-cli.jar -s http://localhost:8080/ create-credentials-by-xml system::system::jenkins _  < cred_key.xml";
echo "Adding Docker credentials"
docker exec -ti $DOCKER_CONTAINER sh -c "java -jar jenkins-cli.jar -s http://localhost:8080/ create-credentials-by-xml system::system::jenkins _  < docker-cred.xml";
echo "Adding Node worker on Hosting machine with label 'Host_Node'"
docker exec -ti $DOCKER_CONTAINER sh -c "java -jar jenkins-cli.jar -s http://localhost:8080/ groovy = < slave.groovy";
echo "Starting Project!"
docker exec -ti $DOCKER_CONTAINER sh -c "java -jar jenkins-cli.jar -s http://localhost:8080/ groovy = < project.groovy";



# settings Consul Servers, agents on HA Proxy and locally
cd /home/ubuntu/src/yamls
ansible-playbook -i ansible_hosts consul_servers.yaml
ansible-playbook -i ansible_hosts consul_k8s.yaml
ansible-playbook -i ansible_hosts consul_haproxy.yaml