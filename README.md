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
This will run `fair init` in CI mode within the given location.

Additional options are available under the `with` tag:

|**Option**|**Description**|
|---|---|
|`cmd`| `fair` command to run (all except `init`) |
|`cli_branch`| Use alternative git branch for the FAIR-CLI |
|`registry_tag`| Use alternative tag for the FAIR data registry |
