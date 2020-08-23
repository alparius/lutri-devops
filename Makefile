.PHONY: agent

THIS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# ██████   ██████   ██████ ██   ██ ███████ ██████  
# ██   ██ ██    ██ ██      ██  ██  ██      ██   ██ 
# ██   ██ ██    ██ ██      █████   █████   ██████  
# ██   ██ ██    ██ ██      ██  ██  ██      ██   ██ 
# ██████   ██████   ██████ ██   ██ ███████ ██   ██ 

docker-backend:
	docker build -t alparius/lutri-backend -f ./lutri-backend/Dockerfile.build ./lutri-backend/
	docker push alparius/lutri-backend

docker-frontend:
	docker build -t alparius/lutri-frontend ./lutri-frontend/
	docker push alparius/lutri-frontend

docker-logstash:
	docker build -t alparius/logstash -f ./devops/elk-stack/Dockerfile.oc-logstash ./devops/elk-stack/
	docker push alparius/logstash


#  ██████  ██████  ███████ ███    ██ ███████ ██   ██ ██ ███████ ████████ 
# ██    ██ ██   ██ ██      ████   ██ ██      ██   ██ ██ ██         ██    
# ██    ██ ██████  █████   ██ ██  ██ ███████ ███████ ██ █████      ██    
# ██    ██ ██      ██      ██  ██ ██      ██ ██   ██ ██ ██         ██    
#  ██████  ██      ███████ ██   ████ ███████ ██   ██ ██ ██         ██ 

# the base stack: mongodb, golang backend, react frontend

lutri-up:
	oc apply -k ./devops/kubernetes/base

lutri-scale:
	oc apply -k ./devops/kubernetes/production

lutri-down:
	oc delete -k ./devops/kubernetes/base

# prometheus and grafana

promgraf-up:
	oc apply -f ./devops/prometheus-grafana

promgraf-down:
	oc delete -f ./devops/prometheus-grafana
	

#      ██ ███████ ███    ██ ██   ██ ██ ███    ██ ███████ 
#      ██ ██      ████   ██ ██  ██  ██ ████   ██ ██      
#      ██ █████   ██ ██  ██ █████   ██ ██ ██  ██ ███████ 
# ██   ██ ██      ██  ██ ██ ██  ██  ██ ██  ██ ██      ██ 
#  █████  ███████ ██   ████ ██   ██ ██ ██   ████ ███████ 

jenkins-agent:
	java -jar ./devops/jenkins/agent.jar -jnlpUrl ${JENKINS_AGENT_URL} -secret ${JENKINS_SECRET} -workDir "/c/Users/cseke.alpar/jenkins"

# jenkins agent runs on WSL so no cross-compile bugs
docker-backend-jenkins:
	docker build -t alparius/lutri-backend -f ./lutri-backend/Dockerfile.nobuild ./lutri-backend/
	docker push alparius/lutri-backend

# the jenkins agent running in kubernetes for linting, testing and building golang apps
docker-jenkins-agent:
	docker build -t alparius/go-jenkins-agent -f ./devops/jenkins/Dockerfile.go-jenkins-agent ./devops/jenkins
	docker push alparius/go-jenkins-agent


# ███████ ██      ██   ██ 
# ██      ██      ██  ██  
# █████   ██      █████   
# ██      ██      ██  ██  
# ███████ ███████ ██   ██ 

# run logstash locally
logstash-up:
	docker run --rm -it \
		-v ${THIS_DIR}/devops/elk-stack/config.yml:/usr/share/logstash/config/logstash.yml \
		-v ${THIS_DIR}/devops/elk-stack/pipeline/:/usr/share/logstash/pipeline/ \
		-v ${THIS_DIR}/lutri-backend/logs:/tmp/logs \
		-p 5000:5000 \
		-p 5044:5044 \
		docker.elastic.co/logstash/logstash:7.8.1

# run logstash on OC kubernetes

logstash-oc-up:
	oc apply -f ./devops/elk-stack/logstash.yaml

logstash-oc-down:
	oc delete -f ./devops/elk-stack/logstash.yaml