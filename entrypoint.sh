#!/usr/bin/bash
CURWD=$PWD
export FAIR_REGISTRY_DIR=/github/home/.fair/registry
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Create a local bin directory
FAIR_BIN_DIR="$PWD/fair-cli"
mkdir -p $FAIR_BIN_DIR/bin

echo "::group::Install FAIR-CLI"

CLI_URL="https://github.com/FAIRDataPipeline/FAIR-CLI.git"

git clone ${CLI_URL} fair-cli-src
cd fair-cli-src
if [ "${INPUT_REF}" == "latest" ]; then
    INPUT_REF=$(git describe --tags --abbrev=0)
fi
git checkout ${INPUT_REF}
poetry install
poetry run pip install pyinstaller pyinstaller-hooks-contrib graphviz
poetry run pyinstaller -c -F \
    fair/cli.py \
    --collect-all fair \
    --onefile \
    --name fair \
    --hidden-import email_validator \
    --distpath $FAIR_BIN_DIR/bin

echo "::endgroup::"

echo "::group::Performing registry setup"

START_SCRIPT="start_fair_registry"

if [ "$(uname -s)" != "Linux" ] && [ "$(uname -s)" != "Darwin" ]; then
    START_SCRIPT=${START_SCRIPT}.bat
fi

if [ -n "${INPUT_LOCAL_DATA_STORE}" ]; then
    echo "::notice title=Data Store::Setting local data store to: ${CURWD}/${INPUT_LOCAL_DATA_STORE}"
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
    echo "::notice title=Local Registry::Installing local registry to: ${FAIR_REGISTRY_DIR}"
    fair registry install --directory ${FAIR_REGISTRY_DIR}
    ${FAIR_REGISTRY_DIR}/scripts/${START_SCRIPT} -p 8000
else
    INPUT_LOCAL_REGISTRY="default"
fi

if [ -n "${INPUT_REMOTE_REGISTRY}" ]; then
    echo "::notice title=Remote Registry::Installing remote registry to: ${CURWD}/${INPUT_REMOTE_REGISTRY}"
    fair registry install --directory ${CURWD}/${INPUT_REMOTE_REGISTRY}
    ${CURWD}/${INPUT_REMOTE_REGISTRY}/scripts/${START_SCRIPT} -p 8001
else
    INPUT_REMOTE_REGISTRY="default"
fi

echo "::endgroup::"
echo "::group::FAIR Repository Setup"

if [ -n "${INPUT_DIRECTORY}" ]; then
    echo "::notice title=Project Location::Setting project directory to: ${CURWD}/${INPUT_DIRECTORY}"
    if [ ${INPUT_DIRECTORY} -ef ${PWD} ]; then
        echo "Error: Project directory cannot be HOME location"
        exit 1
    fi

    cd ${CURWD}/${INPUT_DIRECTORY}
else
    INPUT_DIRECTORY=${CURWD}
fi

if [ ! -d "$PWD/.fair" ]; then
    git config --global user.name "GitHub Action" > /dev/null
    git config --global user.email "github-action@users.noreply.github.com" > /dev/null
    if [ ! -d "${PWD}/.git" ]; then
        echo "::notice title=Project Initialisation::Initialising Git repository"
        git init > /dev/null
        touch init_file > /dev/null
        git add init_file > /dev/null
        git commit -m "Initialised demo repo" > /dev/null
    fi
    echo "::notice title=Project Initialisation::Initialising FAIR repository"
    $FAIR_BIN_DIR/bin/fair init --ci
    echo "::endgroup::"
fi

echo "::group::CLI Configuration"
LOCAL_CLI_CONFIG=${CURWD}/${INPUT_DIRECTORY}/.fair/cli-config.yaml
GLOBAL_CLI_CONFIG=${HOME}/.fair/cli/cli-config.yaml

echo "::notice title=CLI YAML Update::Updating local and global CLI configurations"
update_cli_config \
    ${CURWD}/${INPUT_LOCAL_REGISTRY}    \
    ${CURWD}/${INPUT_REMOTE_REGISTRY}   \
    ${CURWD}/${INPUT_LOCAL_DATA_STORE}  \
    ${LOCAL_CLI_CONFIG}                 \
    ${GLOBAL_CLI_CONFIG}
echo "::endgroup::"

echo "::group::CLI Export"

echo "::notice title=Updating PATH::Adding '$FAIR_BIN_DIR/bin' to \$PATH in \$GITHUB_ENV"

echo "PATH=$PATH" >> $GITHUB_ENV
echo "$FAIR_BIN_DIR/bin" >> $GITHUB_PATH
echo "FAIR_REGISTRY_DIR=$FAIR_REGISTRY_DIR" >> $GITHUB_ENV

echo "::endgroup::"
