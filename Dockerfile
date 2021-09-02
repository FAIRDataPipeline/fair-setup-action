FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Update Ubuntu and install requirements
RUN apt update
RUN apt upgrade -y
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt install -y python3 python3-pip
RUN apt install -y wget curl git

# Set Python to be Python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Create non-admin user
RUN useradd -ms /bin/bash fairci
USER fairci
WORKDIR /home/fairci

# Install Poetry
RUN python -m pip install poetry

# Add entrypoint script
COPY entrypoint.sh /home/fairci/entrypoint.sh

ENTRYPOINT [ "/bin/bash", "/home/fairci/entrypoint.sh" ]