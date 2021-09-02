FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Update Ubuntu and install requirements
RUN apt update
RUN apt upgrade -y
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt install -y python3 python3-pip
RUN apt install -y wget curl git

# Create non-admin user
RUN useradd -ms /bin/bash fairci
USER fairci
WORKDIR /home/fairci

# Install Poetry
RUN python -m pip install poetry