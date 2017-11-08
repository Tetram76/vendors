# vendors

A dedicated branch by vendor

## Add a new vendor branch

Add XXX vendor branch.

```shell
git remote add XXX <url-or-path-to-XXX-repos>
git checkout --orphan XXX
git rm -rf .
echo "<url-or-path-to-XXX-repos>" > .origin.url
git add .origin.url
git commit -m "Add XXX vendor branch"
```

```shell
git fetch XXX
git read-tree --prefix= -u XXX/master
git commit -m "Synchronized with public repository"
git push -u origin XXX
```

## Append submodule to main repository

```shell
git submodule add  -b XXX   -- "https://github.com/Tetram76/vendors.git" "libs/delphi/XXX"
```
