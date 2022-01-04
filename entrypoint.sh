#!/usr/bin/bash
CURWD=$PWD
export FAIR_REGISTRY_DIR=$HOME/.fair/registry

# Install the FAIR-CLI
if [ "${INPUT_REF}" == "latest" ]; then
    CLI_URL="fair-cli"
else
    CLI_URL="git+https://github.com/FAIRDataPipeline/FAIR-CLI.git@${INPUT_REF}"
fi

python -m pip install ${CLI_URL}

START_SCRIPT="start_fair_registry"

if [ "$(uname -s)" != "Linux" ] && [ "$(uname -s)" != "Darwin" ]; then
    START_SCRIPT=${START_SCRIPT}.bat
fi

if [ -n "${INPUT_LOCAL_DATA_STORE}" ]; then
    echo "[Setup FAIRCLI] Setting local data store to: ${CURWD}/${INPUT_LOCAL_DATA_STORE}"
    mkdir -p ${CURWD}/${INPUT_LOCAL_DATA_STORE}
else
    INPUT_LOCAL_DATA_STORE="default"
fi

if [ "${INPUT_LOCAL_REGISTRY}" == "default" ]; then
    INPUT_LOCAL_REGISTRY=$HOME/.fair/registry
fi

if [ "${INPUT_REMOTE_REGISTRY}" == "default" ]; then
    INPUT_REMOTE_REGISTRY=$HOME/.fair/registry-rem
fi

if [ -n "${INPUT_LOCAL_REGISTRY}" ]; then
    export FAIR_REGISTRY_DIR="${CURWD}/${INPUT_LOCAL_REGISTRY}"
    echo "[Setup FAIRCLI] Installing local registry to: ${FAIR_REGISTRY_DIR}"
    fair registry install --directory ${FAIR_REGISTRY_DIR}
    ${FAIR_REGISTRY_DIR}/scripts/${START_SCRIPT} -p 8000
else
    INPUT_LOCAL_REGISTRY="default"
fi

if [ -n "${INPUT_REMOTE_REGISTRY}" ]; then
    echo "[Setup FAIRCLI] Installing remote registry to: ${CURWD}/${INPUT_REMOTE_REGISTRY}"
    fair registry install --directory ${CURWD}/${INPUT_REMOTE_REGISTRY}
    ${CURWD}/${INPUT_REMOTE_REGISTRY}/scripts/${START_SCRIPT} -p 8001
else
    INPUT_REMOTE_REGISTRY="default"
fi

if [ -n "${INPUT_DIRECTORY}" ]; then
    echo "[Setup FAIRCLI] Setting project directory to: ${CURWD}/${INPUT_DIRECTORY}"
    if [ ${INPUT_DIRECTORY} -ef ${PWD} ]; then
        echo "Error: Project directory cannot be HOME location"
        exit 1
    fi

    cd ${CURWD}/${INPUT_DIRECTORY}
fi

if [ ! -d "$PWD/.fair" ]; then
    git config --global user.name "GitHub Action" > /dev/null
    git config --global user.email "github-action@users.noreply.github.com" > /dev/null
    if [ ! -d "${PWD}/.git" ]; then
        git init > /dev/null
        touch init_file > /dev/null
        git add init_file > /dev/null
        git commit -m "Initialised demo repo" > /dev/null
    fi
    fair init --ci
fi

LOCAL_CLI_CONFIG=${CURWD}/${INPUT_DIRECTORY}/.fair/cli-config.yaml
GLOBAL_CLI_CONFIG=${HOME}/.fair/cli/cli-config.yaml

update_cli_config \
    ${CURWD}/${INPUT_LOCAL_REGISTRY}    \
    ${CURWD}/${INPUT_REMOTE_REGISTRY}   \
    ${CURWD}/${INPUT_LOCAL_DATA_STORE}  \
    ${LOCAL_CLI_CONFIG}                 \
    ${GLOBAL_CLI_CONFIG} 
