#!/usr/bin/bash

# Install the registry
curl https://data.scrc.uk/static/localregistry.sh > localregistry.sh

if [ ! -n "${INPUT_REGISTRY_TAG}" ]; then
    bash localregistry.sh -d ${INPUT_REGISTRY_DIRECTORY}
else
    bash localregistry.sh -d ${INPUT_REGISTRY_DIRECTORY} -t ${INPUT_REGISTRY_TAG}
fi

# Install the FAIR-CLI
export FAIR_CLI_REPO=$HOME/FAIRCLI-repo
wget https://github.com/FAIRDataPipeline/FAIR-CLI/archive/refs/heads/dev.zip -O $FAIR_CLI_REPO.zip
unzip $FAIR_CLI_REPO.zip -d $FAIR_CLI_REPO
cd $FAIR_CLI_REPO
poetry install
poetry shell
cd $HOME