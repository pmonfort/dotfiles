#!/bin/bash

wd=$(pwd | rev |cut -d/ -f -3 | rev | tr / -)

venvdir="/Users/fort/virtualenvs/$wd"

export VIRTUAL_ENV_NAME=$wd

if [[ ! -f "$venvdir/bin/activate" ]]; then
  echo "virtualenv doesn't exist"
  virtualenv "$venvdir"
else
  echo "virtualenv already exists"
fi

echo "$venvdir/bin/activate"
source "$venvdir/bin/activate"
exec bash
