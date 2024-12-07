# Use a smaller base image
FROM debian:bullseye-slim

# Set runner version and arguments for unattended installation
ENV RUNNER_VERSION=2.321.0
ARG DEBIAN_FRONTEND=noninteractive
ARG RUNNER_URL
ARG RUNNER_TOKEN

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl jq libssl1.1 libffi7 ca-certificates sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a user for the runner
RUN useradd -m docker

# Set the working directory
WORKDIR /home/docker/actions-runner

# Download and extract the GitHub Actions runner
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    ./bin/installdependencies.sh

# Fix permissions for the runner directory so the "docker" user can access it
RUN chown -R docker:docker /home/docker/actions-runner

# Switch to the non-root user
USER docker

# Configure the GitHub Actions runner
RUN ./config.sh --url "${RUNNER_URL}" --token "${RUNNER_TOKEN}" --unattended --replace

# Start the runner on container startup
ENTRYPOINT ["./run.sh"]
