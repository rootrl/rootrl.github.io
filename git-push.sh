#/usr/bin/env bash

# git提交
git add .
git commit -m "Blog publish $1" .
git push

# 博客发布
hexo generate -d


