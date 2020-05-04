# Variations on a 'k'
A docker image to handle deploying with `kubectl kustomize` building using environment-variables defined in a `.csv`-file 

This image is stil WIP.

## How it works
The script looks through your [kustomization](kustomization.io) resource tree and finds every `/some/path/to/file.y*ml` via the given reference of a `kustomization.y*ml`.

Then for each of these files it looks for a similarly named `.csv`-file, when it matches this it bakups the resource and rewrites this resource for each line of the `.csv`-file replacing along the way the using `envsubst`.

## What can it do?
```
build-yaml $folder_with_kustomization
```
"explode" your `kustomization` using `.csv`-files
```
deploy $folder_with_kustomization
```
is very simple, pipe the built `yaml` into `envsubst` then `kubectl apply -f -`


## Notes
- this breaks the working directory!
it is meant for a pipeline, where the file-tree is scrapped anyway.
- Use the flag `$VARIATIONS_ON_A_K_DEBUG` and output debug.log to check debug statements (TODO, more statements, also maybe a function to just output this)
- tip: use `DOLLAR='$'` for a value `MY_VAR` that persist all the way to the deployment: `${DOLLAR}{DOLLAR}{MY_VAR}` or substituted at "global" scope `${DOLLAR}{MY_VAR}`.
- remember to change deployment names and labels
- check what you can and can't do in `envsubst`
- I have no idea how this works with many deployments (I also have no idea how kubernetes or kubectl handles a very very long deployment config) I am usually only using it for a small amount sub 20 deployments
- there are probably a lot of bugs still
- there are probably many use cases where this is not working
- the csv-handling is very plain, it uses `IFS="${VARIATIONS_ON_A_K_DELIMITER}"`, removes a last semicolon if that is set, and requires it to be line-separated (this should be fixed at some point?) 
