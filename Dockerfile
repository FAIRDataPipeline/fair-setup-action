FROM ubuntu:21.10
ENV DEBIAN_FRONTEND=noninteractive

# Update Ubuntu and install requirements
RUN apt update
RUN apt install -y python3 python3-pip python3-venv python3.9-venv python3-distutils
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt install -y wget curl git zip unzip

# Install Poetry
RUN pip install poetry PyYAML

# Add entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Copy TOML update script
COPY update_cli_config.py /usr/bin/update_cli_config
RUN chmod +x /usr/bin/update_cli_config

ENTRYPOINT [ "/entrypoint.sh" ]