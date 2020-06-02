# Variations on a 'k'
A docker image to do simple templating expansion of a yaml-file 

## What can it do?
```
variations-on-a-k {build|deploy} [--debug] [any command(s) to be piped into kubectl (e.g. -n my-namespace)] -- [files/to/apply]
```
- build: "explode" your `kustomization` using `.csv`-files output kustiomized `yaml`
- deploy: call the build-command into ` envsubst` then `kubectl apply $extra_commands -f -`
- build your yaml with the `--debug`-flag to check debug statements.

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
        MARIE: seven
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
