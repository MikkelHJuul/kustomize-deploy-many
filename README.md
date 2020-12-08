# Variations on a 'k'
A docker image to do simple templating expansion of yaml-files (or any file for that matter!).

It's also a simple docker image with `bash`, `kubectl`, `yq` and `envsubst` via `gettext-base`.

## How do I run it
```
variations-on-a-k [--debug] [files/to/apply]
```
build your yaml with the `--debug`-flag to check debug statements.

### `variation.yaml`
```yaml
apiVersion: variation.config.k8s.io/v1beta1  #not sure this is allowed for legal reasons, so it may change
kind: ConfigVariation
variations:
- targetConfig: my-config.yaml  # relative path
  vary:
    csvSource: some.csv  # relative path
    literals:
      - JOHN: one
        INGRID: two
        MARIE: three
      - JOHN: five
        INGRID: six
        MARIE: '$JOHN and $INGRID is eleven'
- targetConfig: my-other-config.yaml
  vary:
    literals:
      - something: FOO
        other: BAR
        else: BAZ
      - something: foo
        other: bar
extraConfigs:
- some-config.yaml
- other-config.yaml
```

## Notes
- tip: use `DOLLAR='$'` for a value `MY_VAR` that persist all the way to the deployment: `${DOLLAR}{DOLLAR}{MY_VAR}` or substituted at "global" scope `${DOLLAR}{MY_VAR}` (for `variations-on-a-k deploy -- [files]`).
- check what you can and can't do in `envsubst`
- I have no idea how this works with many deployments (I also have no idea how kubernetes or kubectl handles a very very long deployment config) I am usually only using it for a small amount sub 20 deployments
- the csv-handling is very plain, and very hacky: see hacky solution from [terdon|stackoverflow](https://unix.stackexchange.com/questions/149661/handling-comma-in-string-values-in-a-csv-file#answer-149681) which is used to escape commas inside '"' and then replace `,` with `¤` which is used as `IFS='¤' list=($str_with_¤_in_it_in_stead_of_commas)` (`¤` is natively `shift-4` on danish keyboards).
- last but very important: escape `"` inside text with double backslash - `\\"` (e.g. in json `MY_VAR: "\\"string\\":123"` replaces `$MY_VAR` with `"\"string\":123"` which is required for your kubernetes config to be parsed properly).

## Releaselog
### 0.4.0
- changes to the Dockerfile solely. No longer inherits from `bitnami/kubectl`.
..uses `ubuntu`, and `kubectl` via `lachlanevenson/k8s-kubectl` shouldn't change anything from 0.3.0.
..This is the release candidate for 1.0.0. But I may just write this as a go-program in stead.
### 0.3.0
- removed a dangling, wrongfully tagged docker image.
- This is now a single entrance script.
- simplified some code
### 0.2.2
- fixed a bug where I used `yq r - -j` which sorted the array alphabetically. Breaking the feature added in 0.2.1.
### 0.2.1
- fixed namespacing of apiVersion, from variation.configs... to variation.config (as used by other projects)
- added feature "in-place parameter expansion" of literals and csv values to be able to handle local expansion at that context point.
### 0.2.0
changed from csv-only and kustomize-scanning to its own merits
### 0.1.2 and 0.1.1
bugfixes
### 0.1.0
first release
