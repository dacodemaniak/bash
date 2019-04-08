#!/bin/bash

##
# Création des vhosts Apache
# Usage :
# ./addVhost vhost_name [use_ssl]
##

if [ $# == 0 ]
then
	echo "To few arguments to process. Operation failed"
	exit -1
fi
