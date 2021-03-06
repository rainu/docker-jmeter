#!/bin/bash

####
# Variables
####

DOCKER_IMAGE="rainu/jmeter"

CUR_USER_ID=$(id -u)
CUR_USER_GID=$(id -g)

HOST_PROFILE="$HOME/.docker/$DOCKER_IMAGE"

JMETER_ARGS=""
DOCKER_ARGS=""

DOCKER_NAME="jmeter-$CUR_USER_ID"
read -r -d '' DOCKER_RUN_PARAMS <<EOF
--env LANG=$LANG 
--env LANGUAGE=$LANGUAGE 
--env DISPLAY=$DISPLAY
--volume /tmp/.X11-unix:/tmp/.X11-unix 
EOF

####
# Functions
####

execute() {
	SCRIPT=$(mktemp)

	echo $@ > $SCRIPT
	chmod +x $SCRIPT

	$SCRIPT
	RC=$?
	rm $SCRIPT

	return $RC
}

showHelp() {
echo 'Starts the JMeter docker container.

docker-jmeter.sh [OPTIONS...]

Options:
	-h, -help
		Shows this help text
	-D, --docker
		Additional argument to docker command
	-x, --xarg
		Argument(s) for the underlying IntelliJ
'
	exit 0
}

readArguments() {
	while [[ $# > 0 ]]; do
		key="$1"

		case $key in
		    -x|-xargs)
		    INTELLIJ_ARGS=$INTELLIJ_ARGS" $2"
		    shift
		    ;;
		    -D|--docker)
		    DOCKER_ARGS=$DOCKER_ARGS" $2"
		    shift
		    ;;
		    -h|--help)
		    showHelp
		    ;;
		    *)
			    # unknown option
		    ;;
		esac
		shift # past argument or value
	done
}

####
# Main
####

readArguments "$@"

DOCKER_CONTAINER_EXISTS=$(docker ps -a | grep $DOCKER_NAME | wc -l)

if [ "$DOCKER_CONTAINER_EXISTS" == "0" ]; then
	mkdir -p $HOST_PROFILE
	chmod 777 $HOST_PROFILE

	execute docker run \
	    --detach \
	    --name "$DOCKER_NAME" \
	    $DOCKER_RUN_PARAMS \
	    $DOCKER_ARGS \
	    $DOCKER_IMAGE \
	    $JMETER_ARGS
else
	execute docker start $DOCKER_NAME
fi

execute docker attach $DOCKER_NAME
exit $?
