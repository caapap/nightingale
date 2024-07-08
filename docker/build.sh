#!/bin/sh
if [ $# -ne 1 ]; then
	echo "$0 <tag>"
	exit 0
fi

tag=$1

echo "tag: ${tag}"

rm -rf n9e pub
cp ../n9e .
cp -r ../integrations .
cp -r ../etc .

docker build -t stellar:${tag} .

docker tag stellar:${tag} docker.kxdigit.com/n9e/stellar:${tag}
docker push docker.kxdigit.com/n9e/stellar:${tag}

rm -rf n9e pub
