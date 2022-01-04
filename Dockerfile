FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Update Ubuntu and install requirements
RUN apt update
RUN apt upgrade -y
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt install -y python3 python3-pip python3-venv python3-dev
RUN apt install -y wget curl git zip unzip

# Set Python to be Python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Poetry
RUN python -m pip install pyyaml poetry

# Add entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Copy TOML update script
COPY update_cli_config.py /usr/bin/update_cli_config
RUN chmod +x /usr/bin/update_cli_config

ENTRYPOINT [ "/entrypoint.sh" ]