# ██████   ██████   ██████ ██   ██ ███████ ██████  
# ██   ██ ██    ██ ██      ██  ██  ██      ██   ██ 
# ██   ██ ██    ██ ██      █████   █████   ██████  
# ██   ██ ██    ██ ██      ██  ██  ██      ██   ██ 
# ██████   ██████   ██████ ██   ██ ███████ ██   ██ 

backend:
	docker build -t alparius/lutri-backend ./lutri-backend/
	docker push alparius/lutri-backend

frontend:
	docker build -t alparius/lutri-frontend ./lutri-frontend/
	docker push alparius/lutri-frontend

# the jenkins agent running in kubernetes for linting, testing and building golang apps
docker-jenkins-agent:
	docker build -t alparius/go-jenkins-agent -f ./devops/jenkins/Dockerfile.go-jenkins-agent ./devops/jenkins
	docker push alparius/go-jenkins-agent


#  ██████  ██████  ███████ ███    ██ ███████ ██   ██ ██ ███████ ████████ 
# ██    ██ ██   ██ ██      ████   ██ ██      ██   ██ ██ ██         ██    
# ██    ██ ██████  █████   ██ ██  ██ ███████ ███████ ██ █████      ██    
# ██    ██ ██      ██      ██  ██ ██      ██ ██   ██ ██ ██         ██    
#  ██████  ██      ███████ ██   ████ ███████ ██   ██ ██ ██         ██ 

# the base stack: mongodb, golang backend, react frontend

lutri-up:
	oc apply -k ./devops/lutri/base

lutri-down:
	oc delete -k ./devops/lutri/base

# prometheus and grafana

promgraf-up:
	oc apply -f ./devops/prometheus-grafana

promgraf-down:
	oc delete -f ./devops/prometheus-grafana
