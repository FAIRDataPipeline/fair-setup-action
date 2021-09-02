#!/usr/bin/bash
CURWD=$PWD

# Install the registry
curl https://data.scrc.uk/static/localregistry.sh > localregistry.sh

if [ ! -n "${INPUT_REGISTRY_TAG}" ]; then
    bash localregistry.sh -d ${INPUT_REGISTRY_DIRECTORY} > /dev/null
else
    bash localregistry.sh -d ${INPUT_REGISTRY_DIRECTORY} -t ${INPUT_REGISTRY_TAG} > /dev/null
fi

# Install the FAIR-CLI
export FAIR_CLI_REPO=$HOME/FAIRCLI-repo
git clone --depth 1 -b ${INPUT_CLI_BRANCH} https://github.com/FAIRDataPipeline/FAIR-CLI.git $FAIR_CLI_REPO > /dev/null
cd $FAIR_CLI_REPO
poetry build > /dev/null
python -m pip install jinja2 > /dev/null
python -m pip install fair-cli --find-links=dist/ > /dev/null
export PATH=$HOME/.local/bin:$PATH

if [ -n "${INPUT_DIRECTORY}" ]; then
    if [ ${INPUT_DIRECTORY} -ef ${PWD} ]; then
        echo "Error: Project directory cannot be HOME location"
        exit 1
    fi
    cd ${CURWD}/${INPUT_DIRECTORY}
else
    echo "Error: Expected FAIR project directory"
    exit 1
fi

# Only initialise if there is no fair directory
if [ ! -d "$PWD/.fair" ]; then
    fair init --ci
fi

# Execute any fair subcommand specified
# for 'fair run' make sure to add --ci flag if
# it is not already present

if [ ! -n "${INPUT_CMD}" ]; then
    RUN_CMD=' run'
    CI_FLAG='--ci'
    if [[ $RUN_CMD == *"${INPUT_CMD}"* && $CI_FLAG != *"${INPUT_CMD}"* ]]; then
        FLAGS='--ci'
    else
        FLAGS=''
    fi
    fair ${INPUT_CMD} ${FLAGS}
fi
