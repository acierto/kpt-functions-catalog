# generate-kpt-pkg-docs

## Overview

<!--mdtogo:Short-->

The `generate-kpt-pkg-docs` function generates opinionated documentation for a [kpt package](https://kpt.dev/book/02-concepts/01-packages).

It works by analyzing the kpt package to generate markdown documentation and writes it to a file.

<!--mdtogo-->

<!--mdtogo:Long-->

## Usage

The `generate-kpt-pkg-docs` function is expected to be executed imperatively like:

```shell
$ kpt fn eval -i generate-kpt-pkg-docs:unstable --include-meta-resources \
--mount type=bind,src="$(pwd)",dst="/tmp",rw=true
```

## FunctionConfig

This function supports `ConfigMap` `functionConfig`.

- A `readme-path` can be provided to write to a specific file. If a `readme-path` is not provided, it defaults to `/tmp/README.md`. If the file specified via `readme-path` does not exist, readme generation is skipped with a warning.

- A `repo-path` can be provided to include in usage section. This will generate a usage section with sample commands like `kpt pkg get ${repo-path}/{pkg-name}@version`. If a `repo-path` is not provided, it defaults to `https://github.com/GoogleCloudPlatform/blueprints.git/catalog`.

- A `pkg-name` can be provided to include in usage section. This will generate a usage section with sample commands like `kpt pkg get ${repo-path}/{pkg-name}@version`. If a `pkg-name` is not provided, it defaults to the name specified in the Kptfile.

The `generate-kpt-pkg-docs` function does the following:

1. Scans the package contents including meta resources like Kptfile(s) and function configs.
1. Generates readme contents in markdown format and inserts it between HTML comments.

    - Generated title content is inserted between the markers `<!-- BEGINNING OF PRE-COMMIT-BLUEPRINT DOCS HOOK:TITLE -->` and `<!-- END OF PRE-COMMIT-BLUEPRINT DOCS HOOK:TITLE -->` if present.
    - Generated body content is inserted between the markers `<!-- BEGINNING OF PRE-COMMIT-BLUEPRINT DOCS HOOK:BODY -->` and `<!-- END OF PRE-COMMIT-BLUEPRINT DOCS HOOK:BODY -->` if present.
    - Any additional content not between the markers are preserved.

1. Writes the generated readme to `readme-path`.

<!--mdtogo-->

## Examples

<!--mdtogo:Examples-->

Let's start with a sample blueprint.

```yaml
# Kptfile
apiVersion: kpt.dev/v1
kind: Kptfile
metadata:
  name: bucket
  annotations:
    blueprints.cloud.google.com/title: Google Cloud Storage Bucket blueprint
info:
  description: A Google Cloud Storage bucket
pipeline:
  mutators:
    - image: gcr.io/kpt-fn/apply-setters:v0.1
      configPath: setters.yaml
```

```yaml
# bucket.yaml
apiVersion: storage.cnrm.cloud.google.com/v1beta1
kind: StorageBucket
metadata:
  name: blueprints-project-bucket # kpt-set: ${project-id}-${name}
  namespace: config-control # kpt-set: ${namespace}
  annotations:
    cnrm.cloud.google.com/force-destroy: "false"
    cnrm.cloud.google.com/project-id: blueprints-project # kpt-set: ${project-id}
spec:
  location: us-central1
  storageClass: standard # kpt-set: ${storage-class}
  uniformBucketLevelAccess: true
  versioning:
    enabled: false
```

```yaml
# setters.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: setters
data:
  name: bucket2
  namespace: config-control
  project-id: project-id
  storage-class: standard
```

and a sample readme with HTML markers.

```markdown
[//]: #README.md
<!-- BEGINNING OF PRE-COMMIT-BLUEPRINT DOCS HOOK:TITLE -->

<!-- END OF PRE-COMMIT-BLUEPRINT DOCS HOOK:TITLE -->
<!-- BEGINNING OF PRE-COMMIT-BLUEPRINT DOCS HOOK:BODY -->

<!-- END OF PRE-COMMIT-BLUEPRINT DOCS HOOK:BODY -->
```

Invoke the function:

```shell
$ kpt fn eval -i generate-kpt-pkg-docs:unstable --include-meta-resources \
--mount type=bind,src="$(pwd)",dst="/tmp",rw=true -- readme-path=/tmp/README.md
```

The following readme will be created:

```markdown
[//]: #README.md
<!-- BEGINNING OF PRE-COMMIT-BLUEPRINT DOCS HOOK:TITLE -->
# Google Cloud Storage Bucket blueprint

<!-- END OF PRE-COMMIT-BLUEPRINT DOCS HOOK:TITLE -->
<!-- BEGINNING OF PRE-COMMIT-BLUEPRINT DOCS HOOK:BODY -->
A Google Cloud Storage bucket

## Setters

|     Name      |       Value        | Type | Count |
|---------------|--------------------|------|-------|
| name          | bucket             | str  |     1 |
| namespace     | config-control     | str  |     1 |
| project-id    | blueprints-project | str  |     2 |
| storage-class | standard           | str  |     1 |

## Sub-packages

This package has no sub-packages.

## Resources

|    File     |              APIVersion               |     Kind      |           Name            |   Namespace    |
|-------------|---------------------------------------|---------------|---------------------------|----------------|
| bucket.yaml | storage.cnrm.cloud.google.com/v1beta1 | StorageBucket | blueprints-project-bucket | config-control |

## Resource References

- [StorageBucket](https://cloud.google.com/config-connector/docs/reference/resource-docs/storage/storagebucket)

## Usage

1.  Clone the package:
    ```shell
    kpt pkg get https://github.com/GoogleCloudPlatform/blueprints.git/catalog/bucket@${VERSION}
    ```
    Replace `${VERSION}` with the desired repo branch or tag
    (for example, `main`).

1.  Move into the local package:
    ```shell
    cd "./bucket/"
    ```

1.  Edit the function config file(s):
    - setters.yaml

1.  Execute the function pipeline
    ```shell
    kpt fn render
    ```

1.  Initialize the resource inventory
    ```shell
    kpt live init --namespace ${NAMESPACE}"
    ```
    Replace `${NAMESPACE}` with the namespace in which to manage
    the inventory ResourceGroup (for example, `config-control`).

1.  Apply the package resources to your cluster
    ```shell
    kpt live apply
    ```

1.  Wait for the resources to be ready
    ```shell
    kpt live status --output table --poll-until current
    ```
<!-- END OF PRE-COMMIT-BLUEPRINT DOCS HOOK:BODY -->
```
<!--mdtogo-->
