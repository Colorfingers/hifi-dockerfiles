build-base:
	docker build -t highfidelity/build-base:latest -f Dockerfile.build_base .
	docker push highfidelity/build-base:latest

assignment-client: build-base
	docker build -t highfidelity/assignment-client:latest -f Dockerfile.build_assignment_client .
	docker push highfidelity/assignment-client:latest
