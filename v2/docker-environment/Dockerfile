FROM ubuntu:20.04

ENV TZ=America/Mexico_City
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Run the Update
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y awscli openssh-server
# RUN apt-get -y update && apt-get install -y awscli

RUN apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update -y

RUN apt-get install -y docker-ce-cli

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

RUN . ~/.bashrc && nvm install 12.14.1

ENV LIBERA_BOCC_HOME=/lbocc

WORKDIR ${LIBERA_BOCC_HOME}/libera-bocc-scf-devops/v2