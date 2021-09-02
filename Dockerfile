FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Update Ubuntu and install requirements
RUN apt update
RUN apt upgrade -y
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt install -y python3 python3-pip python3-venv
RUN apt install -y wget curl git zip unzip

# Set Python to be Python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Poetry
RUN python -m pip install poetry

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]