build-base:
	docker build -t highfidelity/build-base:latest -f Dockerfile.build_base .
	docker push highfidelity/build-base:latest

assignment-client: build-base
	docker build -t highfidelity/assignment-client:latest -f Dockerfile.build_assignment_client .
	docker push highfidelity/assignment-client:latest

assignment-client-release: build-base
	sed -Ee 's/(^ENV RELEASE_TYPE).*/\1 PRODUCTION/' \
		 -e 's/(^ENV STABLE_BUILD).*/\1 1/' Dockerfile.build_assignment_client | \
		docker build -t highfidelity/assignment-client:release -f- .
	docker push highfidelity/assignment-client:release
