#!/usr/bin/bash
CURWD=$PWD

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

if [ -n "${INPUT_LOCAL_REGISTRY}" ]; then
    echo "Installing local registry to: ${CURWD}/${INPUT_LOCAL_REGISTRY}"
    fair registry install --directory ${CURWD}/${INPUT_LOCAL_REGISTRY}
    ${CURWD}/${INPUT_LOCAL_REGISTRY}/scripts/${START_SCRIPT} -p 8000
fi

if [ -n "${INPUT_REMOTE_REGISTRY}" ]; then
    echo "Installing remote registry to: ${CURWD}/${INPUT_REMOTE_REGISTRY}"
    fair registry install --directory ${CURWD}/${INPUT_REMOTE_REGISTRY}
    ${CURWD}/${INPUT_REMOTE_REGISTRY}/scripts/${START_SCRIPT} -p 8001
fi

if [ -n "${INPUT_DIRECTORY}" ]; then
    echo "Setting project directory to: ${CURWD}/${INPUT_DIRECTORY}"
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
