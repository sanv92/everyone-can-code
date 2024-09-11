#!/bin/bash

# Add changes to git.
git init
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Add repository
git remote add origin https://github.com/everyone-can-code/everyone-can-code.github.io.git

# Push source and build repos.
git push origin master --force

# Come Back up to the Project Root
cd ..
