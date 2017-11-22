git checkout --orphan $1
git rm -rf .
echo $2 > .origin.url
git add .origin.url
git commit -m "Add $1 vendor branch"

git remote add -t master $1 $2
git fetch -n $1
git merge -X subtree=. --allow-unrelated-histories --no-commit $1/master

git commit -m "Synchronized with public repository"
git push -u origin $1
