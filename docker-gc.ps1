docker ps -aq -f status=exited | % { docker rm -v $_ }
docker images -q -f dangling=true | % { docker rmi $_ }
