assignment-client:
	docker build --build-arg GIT_TAG=v0.76.0 -t highfidelity/assignment-client:latest .
	docker push highfidelity/assignment-client:latest
