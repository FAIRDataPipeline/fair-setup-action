#!/usr/bin/bash
CURWD=$PWD
export FAIR_REGISTRY_DIR=$HOME/.fair/registry
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

mkdir -p $FAIR_CLI_BIN

echo "::group::Install FAIR-CLI"

CLI_URL="https://github.com/FAIRDataPipeline/FAIR-CLI.git"

git clone ${CLI_URL} fair-cli-src
cd fair-cli-src
if [ "${REFERENCE}" == "latest" ]; then
    REF=$(git describe --tags --abbrev=0)
fi
git checkout ${REFERENCE}
poetry install
poetry run pip install pyinstaller pyinstaller-hooks-contrib graphviz
poetry run pyinstaller -c -F \
    fair/cli.py \
    --collect-all fair \
    --onefile \
    --name fair \
    --hidden-import email_validator \
    --distpath $FAIR_BIN_DIR
export FAIR_VERSION=$(poetry run fair --version | cut -d ' ' -f 3)

echo "::endgroup::"

echo "::group::Performing registry setup"

START_SCRIPT="start_fair_registry"

if [ "$(uname -s)" != "Linux" ] && [ "$(uname -s)" != "Darwin" ]; then
    START_SCRIPT=${START_SCRIPT}.bat
fi

if [ -n "${LOCAL_DATA_STORE}" ]; then
    echo "::notice title=Data Store::Setting local data store to: ${CURWD}/${LOCAL_DATA_STORE}"
    mkdir -p ${CURWD}/${LOCAL_DATA_STORE}
else
    LOCAL_DATA_STORE="default"
fi

if [ "${LOCAL_REGISTRY}" == "default" ]; then
    LOCAL_REGISTRY=$HOME/.fair/registry
fi

if [ "${REMOTE_REGISTRY}" == "default" ]; then
    REMOTE_REGISTRY=$HOME/.fair/registry-rem
fi

if [ -n "${LOCAL_REGISTRY}" ]; then
    export FAIR_REGISTRY_DIR="${CURWD}/${LOCAL_REGISTRY}"
    echo "::notice title=Local Registry::Installing local registry to: ${FAIR_REGISTRY_DIR}"
    $FAIR_BIN_DIR/fair registry install --directory ${FAIR_REGISTRY_DIR}
    ${FAIR_REGISTRY_DIR}/scripts/${START_SCRIPT} -p 8000
else
    LOCAL_REGISTRY="default"
fi

if [ -n "${REMOTE_REGISTRY}" ]; then
    echo "::notice title=Remote Registry::Installing remote registry to: ${CURWD}/${REMOTE_REGISTRY}"
    $FAIR_BIN_DIR/fair registry install --directory ${CURWD}/${REMOTE_REGISTRY}
    ${CURWD}/${REMOTE_REGISTRY}/scripts/${START_SCRIPT} -p 8001
else
    REMOTE_REGISTRY="default"
fi

echo "::endgroup::"
echo "::group::FAIR Repository Setup"

echo "::notice title=Project Location::Setting project directory to: ${CURWD}/${PROJECT_DIRECTORY}"
cd ${PROJECT_DIRECTORY}

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
    $FAIR_BIN_DIR/fair init --ci
    echo "::endgroup::"
fi

echo "::group::CLI Export"

echo "::notice title=Updating PATH::Adding '$FAIR_BIN_DIR' to \$PATH in \$GITHUB_ENV"

export PATH=$FAIR_BIN_DIR:${PATH}
echo "PATH=$PATH" >> $GITHUB_ENV

echo "::endgroup::"
