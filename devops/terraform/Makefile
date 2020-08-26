.PHONY: up down newinstance newdeploy

up:
	tf apply --auto-approve

down:
	tf destroy --auto-approve


newinstance:
	tf taint aws_instance.web
	tf apply --auto-approve

newdeploy:
	tf taint aws_api_gateway_deployment.meteo_deployment
	tf apply --auto-approve