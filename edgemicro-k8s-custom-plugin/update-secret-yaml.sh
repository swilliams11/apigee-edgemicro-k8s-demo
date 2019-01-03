#!/bin/bash

. microgateway.sh

new_dir="/updated_secret"
cp ./secret.yaml $new_dir
#echo `ls -la $new_dir`

export EMORG=`echo -n $EM_ORG | base64 | tr -d '\n'`
export EMENV=`echo -n $EM_ENV | base64 | tr -d '\n'`
export EMKEY=`echo -n $EM_KEY | base64 | tr -d '\n'`
export EMSECRET=`echo -n $EM_SECRET | base64 | tr -d '\n'`
export EDGEMICROCONFIG=`cat ./$EM_ORG-$EM_ENV-config.yaml | base64 | tr -d '\n' | base64  | tr -d '\n'`

sed -i 's/EM_ORG/'"$EMORG"'/g' $new_dir/secret.yaml
sed -i 's/EM_ENV/'"$EMENV"'/g' $new_dir/secret.yaml
sed -i 's/EM_KEY/'"$EMKEY"'/g' $new_dir/secret.yaml
sed -i 's/EM_SECRET/'"$EMSECRET"'/g' $new_dir/secret.yaml
sed -i 's/EDGEMICRO_CONFIG/'"$EDGEMICROCONFIG"'/g' $new_dir/secret.yaml

#cat $new_dir/secret.yaml
