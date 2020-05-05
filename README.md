# Variations on a 'k'
A docker image to handle deploying with `kubectl kustomize` building using environment-variables defined in a `.csv`-file 

This image is stil WIP.

## How it works
The script looks through your [kustomization](kustomization.io) resource tree and finds every `/some/path/to/file.y*ml` via the given reference of a `kustomization.y*ml`.

Then for each of these files it looks for a similarly named `.csv`-file, when it matches this it bakups the resource and rewrites this resource for each line of the `.csv`-file replacing along the way the using `envsubst`.

## What can it do?
```
variations-on-a-k {build|clean|debug|deploy} {folder_with_kustomization} [--debug]
```
- build: "explode" your `kustomization` using `.csv`-files output kustiomized `yaml`
- clean: clean up /revert the `kustomization` resources that the other commands has changed
- debug: print the build-command to debug.log and output this to stdout
- deploy: call the build-command into ` envsubst` then `kubectl apply -f -` (see notes concerning `DOLLAR`)
- Use the flag `--debug` and output debug.log to check debug statements 
is very simple, pipe the built `yaml` into `envsubst` then `kubectl apply -f -`


## Notes
- the commands leaves the working directory broken!
it is meant for a pipeline, where the file-tree is scrapped anyway. Use `variations-on-a-k clean dir/` to revert constructed `.bak`-files.
- tip: use `DOLLAR='$'` for a value `MY_VAR` that persist all the way to the deployment: `${DOLLAR}{DOLLAR}{MY_VAR}` or substituted at "global" scope `${DOLLAR}{MY_VAR}` (for `variations-on-a-k deploy dir/`).
- remember to change deployment names and labels
- check what you can and can't do in `envsubst`
- I have no idea how this works with many deployments (I also have no idea how kubernetes or kubectl handles a very very long deployment config) I am usually only using it for a small amount sub 20 deployments
- there are probably a lot of bugs still
- there are probably many use cases where this is not working
- the csv-handling is very plain, and very hacky: see hacky solution from [terdon|stackoverflow](https://unix.stackexchange.com/questions/149661/handling-comma-in-string-values-in-a-csv-file#answer-149681) which is used to escape commas inside '"' and then replace `,` with `¤` which is used as `IFS='¤' list=($str_with_¤_in_it_in_stead_of_commas)` (`¤` is natively `shift-4` on danish keyboards).
- last but very important: escape `"` inside text with double backslash - `\\"` (e.g. in json `"\\"string\\":123"` replaces `$MY_VAR` with `"\"string\":123"` which is required for your kubernetes config to be parsed properly).
