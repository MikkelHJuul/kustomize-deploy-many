# Variations of a 'k'
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
is simply very simple, pipe the built `yaml` into `envsubst` then `kubectl apply -f -`
