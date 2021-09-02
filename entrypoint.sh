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
git clone --depth 1 -b ${INPUT_CLI_BRANCH} https://github.com/FAIRDataPipeline/FAIR-CLI.git $FAIR_CLI_REPO
cd $FAIR_CLI_REPO
poetry build
python -m pip install jinja2
python -m pip install fair-cli --find-links=dist/
export PATH=$HOME/.local/bin:$PATH 
cd $HOME
rm -rf $FAIR_CLI_REPO