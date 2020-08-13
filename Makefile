.PHONY: agent


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


#  ██████  ██████  ███████ ███    ██ ███████ ██   ██ ██ ███████ ████████ 
# ██    ██ ██   ██ ██      ████   ██ ██      ██   ██ ██ ██         ██    
# ██    ██ ██████  █████   ██ ██  ██ ███████ ███████ ██ █████      ██    
# ██    ██ ██      ██      ██  ██ ██      ██ ██   ██ ██ ██         ██    
#  ██████  ██      ███████ ██   ████ ███████ ██   ██ ██ ██         ██ 

# the base stack: mongodb, golang backend, react frontend

lutri-up:
	oc apply -k ./devops/lutri/base

lutri-scale:
	oc apply -k ./devops/lutri/production

lutri-down:
	oc delete -k ./devops/lutri/base

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

agent:
	java -jar ./devops/jenkins/agent.jar -jnlpUrl http://jenkins.apps.okd.codespring.ro/computer/lutri-local-agent/slave-agent.jnlp -secret df307f2ac8c5f3488c03a493e491655d6d57a1ada55952b2b4ba0bc03eaddf3c -workDir "/c/Users/cseke.alpar/jenkins"

# jenkins agent runs on WSL so no cross-compile bugs
docker-backend-jenkins:
	docker build -t alparius/lutri-backend -f ./lutri-backend/Dockerfile.nobuild ./lutri-backend/
	docker push alparius/lutri-backend

# the jenkins agent running in kubernetes for linting, testing and building golang apps
docker-jenkins-agent:
	docker build -t alparius/go-jenkins-agent -f ./devops/jenkins/Dockerfile.go-jenkins-agent ./devops/jenkins
	docker push alparius/go-jenkins-agent