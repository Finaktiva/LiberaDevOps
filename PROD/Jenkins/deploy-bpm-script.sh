HOME=""
echo "starting deploy of instance content"
sudo rm -rf LIBERA_BPMN_HOME
mkdir LIBERA_BPMN_HOME
$(aws ecr get-login --no-include-email --region us-west-2)
docker stop $(docker ps | grep engine | awk '{print $1}')
docker rmi -f $(docker images -a | grep engine | awk '{print $3}')
docker pull 949050634862.dkr.ecr.us-east-1.amazonaws.com/libera-scf/bpmn-engine:prod
docker run -itd -p 8080:8080 -v "liberaBpmnHomeVolume:/opt/LIBERA_BPMN_HOME" 949050634862.dkr.ecr.us-east-1.amazonaws.com/libera-scf/bpmn-engine:prod