# Vendors

A dedicated branch by vendor

## Add a new vendor branch

This adds XXX vendor branch.

### Prepare the branch

```shell
git checkout --orphan XXX
git rm -rf .
echo "<url-or-path-to-XXX-repos>" > .origin.url
# if needed :
# echo <Login> > .origin.login
# echo <Pwd> > .origin.password
git add .origin.*
git commit -m "Add XXX vendor branch"
```

### Get the files

#### From a GIT source

```shell
git remote add -t master XXX "`cat .origin.url`"
git fetch -n XXX
git merge -X subtree=. --allow-unrelated-histories --no-commit XXX/master
```

#### From a SVN source

```shell
svn checkout "`cat .origin.url`" .
git add .
git rm -rf .svn
```

### Commit & Push

```shell
git commit -m "Synchronized with public repository"
# if remote does not exist already
git remote add origin https://github.com/Tetram76/vendors.git
# and then 
git push -u origin XXX
```

## Append submodule to main repository

**__From main repository root:__**

```shell
git submodule add -b XXX   -- "https://github.com/Tetram76/vendors.git" "libs/delphi/XXX"
```

## Remove submodule from main repository

**__From main repository root:__**

```shell
git submodule deinint --force libs/delphi/XXX
git rm libs/delphi/XXX
rm -rf .git/modules/libs/delphi/XXX
```

## Update an existing vendor branch

This update XXX vendor branch.

### Prepare the branch

```shell
# if the repository is not cloned
git clone -b XXX https://github.com/Tetram76/vendors.git
# else (also if the repository is not cloned yet)
# check if a local branch already exists
git branch
# if the branch exists
git checkout XXX
# else
git checkout --track origin/XXX
# in all cases and to be sure
git pull
```

### Get the files

#### From a GIT source

```shell
# check if the remote exists
git remote
# if remote does not exist yet
git remote add -t master XXX "`cat .origin.url`"
# and then
git fetch -n XXX
git merge -X subtree=. --allow-unrelated-histories --no-commit XXX/master
```

#### From a SVN source

```shell
# will remove not shared modifications
git rm -rf .
svn checkout "`cat .origin.url`" .
git add .
git rm -rf .svn
```

Resolve conflicts if any.

```shell
git add . .svn
```

### Commit & Push

```shell
git reset HEAD .origin.*
git checkout .origin.*
git commit -m "Synchronized with public repository"
git push
```

in case of multiple branch updates, push can be done once
```shell
git push --all
```
