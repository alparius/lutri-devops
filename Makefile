# ██████   ██████   ██████ ██   ██ ███████ ██████  
# ██   ██ ██    ██ ██      ██  ██  ██      ██   ██ 
# ██   ██ ██    ██ ██      █████   █████   ██████  
# ██   ██ ██    ██ ██      ██  ██  ██      ██   ██ 
# ██████   ██████   ██████ ██   ██ ███████ ██   ██ 

backend:
	docker build -t csalparius/lutri-backend ./lutri-backend/
	docker push csalparius/lutri-backend

frontend:
	docker build -t csalparius/lutri-frontend ./lutri-frontend/
	docker push csalparius/lutri-frontend


#  ██████  ██████  ███████ ███    ██ ███████ ██   ██ ██ ███████ ████████ 
# ██    ██ ██   ██ ██      ████   ██ ██      ██   ██ ██ ██         ██    
# ██    ██ ██████  █████   ██ ██  ██ ███████ ███████ ██ █████      ██    
# ██    ██ ██      ██      ██  ██ ██      ██ ██   ██ ██ ██         ██    
#  ██████  ██      ███████ ██   ████ ███████ ██   ██ ██ ██         ██ 

oc-up:
	oc apply -k ./devops/lutri/base

oc-down:
	oc delete -k ./devops/lutri/base

prometheus-up:
	oc apply -f ./devops/prometheus-grafana

prometheus-down:
	oc delete -f ./devops/prometheus-grafana