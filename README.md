# vendors

A dedicated branch by vendor

## Add a new vendor branch

This adds XXX vendor branch.

### Prepare the branch

```shell
git checkout --orphan XXX
git rm -rf .
echo "<url-or-path-to-XXX-repos>" > .origin.url
git add .origin.url
git commit -m "Add XXX vendor branch"
```
### From a GIT source

```shell
git remote add -t master XXX <url-or-path-to-XXX-repos>
git fetch -n XXX
git read-tree --prefix= -u XXX/master
```

### From a SVN source

```shell
svn export <url-or-path-to-XXX-repos> . --force
git add .
```

### Commit & Push


```shell
git commit -m "Synchronized with public repository"
git push -u origin XXX
```


## Append submodule to main repository

From main repository root:

```shell
git submodule add  -b XXX   -- "https://github.com/Tetram76/vendors.git" "libs/delphi/XXX"
```
