#!/usr/bin/bash

# Install the registry
curl https://data.scrc.uk/static/localregistry.sh > localregistry.sh

if [ ! -n "${INPUT_REGISTRY_TAG}" ]; then
    bash localregistry.sh -d ${INPUT_REGISTRY_DIRECTORY}
else
    bash localregistry.sh -d ${INPUT_REGISTRY_DIRECTORY} -t ${INPUT_REGISTRY_TAG}
fi

# Install the FAIR-CLI
export FAIR_CLI_REPO=$HOME/cli-repo
mkdir -p $FAIR_CLI_REPO
wget https://github.com/FAIRDataPipeline/FAIR-CLI/archive/refs/heads/dev.zip -P $FAIR_CLI_REPO
cd $FAIR_CLI_REPO
unzip dev.zip
cd $FAIR_CLI_REPO/dev
poetry install
poetry shell
cd $HOME