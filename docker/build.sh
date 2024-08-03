#!/bin/sh
if [ $# -ne 1 ]; then
	echo "$0 <tag>"
	exit 0
fi

tag=$1

echo "tag: ${tag}"

docker build -t stellar:${tag} .

docker tag stellar:${tag} docker.kxdigit.com/stellar/stellar:${tag}
docker save docker.kxdigit.com/stellar/stellar:${tag} -o stellar-${tag}.tar

