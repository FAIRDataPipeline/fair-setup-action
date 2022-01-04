# fair-setup-action
GitHub Action for installation of the FAIR Data Pipeline and CLI into a CI runner

## Usage

This action requires at minimum the `directory` of the FAIR project.
```yaml
steps:
    - uses: FAIRDataPipeline/fair-setup-action@v1
      with:
        directory: /path/of/fair/project
```
This will run `fair init` in CI mode within the given location, and make the `fair` command available.

Additional options are available under the `with` tag:

|**Option**|**Description**|
|---|---|
|`directory`| directory in which to run `fair init --ci`. If unset use current working directory. |
|`local_registry`| Specify a directory for local registry installation. If unset no registry installed. |
|`remote_registry`| Specify a directory for remote registry installation. If unset no registry installed. |
|`ref`| Specify version of `fair-cli` to use, the default `latest` will install from PyPi the latest version, else a git reference (e.g. repository tag) is used |
