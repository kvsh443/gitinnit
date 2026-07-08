#!/bin/bash
set -e
if [ -f /etc/os-release ]; then
 . /etc/os-release
 if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ] && [[ ! "$ID_LIKE" =~ "debian" ]]; then
  echo "Error: Optimized for Debian/Ubuntu environments."
  exit 1
 fi
else
 exit 1
fi
if ! command -v git &> /dev/null; then
 sudo apt-get update -y
 sudo apt-get install -y git
fi
if ! command -v gh &> /dev/null; then
 (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
 && sudo mkdir -p -m 755 /etc/apt/keyrings \
 && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
 && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
 && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
 && sudo apt update \
 && sudo apt install gh -y
fi
export BROWSER="none"
echo "Y" | gh auth login --hostname github.com --git-protocol https --web --scopes user
u=$(gh api user --jq '.login')
e=$(gh api user/emails --jq '.[].email' | grep 'noreply' | head -n 1 | sed 's/[[:space:]]*//g')
if [ -z "$u" ] || [ -z "$e" ]; then
 exit 1
fi
echo "Variables fetched:"
echo "\$u = $u"
echo "\$e = $e"
git config --global user.name "$u"
git config --global user.email "$e"
git config --global user.name
git config --global user.email
