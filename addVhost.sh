#!/bin/bash

##
# Création des vhosts Apache spécifique Symfony 3
# Usage :
# ./addVhost vhost_name [use_ssl]
##

sudo -v

# Définit le dossier racine des applications Apache
ROOT_DIR="/home/jean-luc/www/"

if [ $# == 0 ]
then
	echo "To few arguments to process. Operation failed"
	exit -1
else
	# Copier le fichier template-symfony vers /etc/apache2/sites-available
	# avec le nom vhost_name.conf
	cp ./template-symfony /etc/apache2/sites-available/$1.conf

	# Créer le dossier dans le dossier /home/jlaubert/www
	mkdir -p $ROOT_DIR$1 $ROOT_DIR$1/web

	# Remplacer "template" par "vhost_name" dans le fichier de configuration
	sudo sed -i 's/template/'$1'/g' /etc/apache2/sites-available/$1.conf

	# Ajouter le fichier de configuration à la liste des sites actifs
	sudo a2ensite $1.conf

	# Mettre à jour le fichier hosts
	echo "127.0.0.1 $1.wrk www.$1.wrk" >> /etc/hosts

	# Vérifier l'exécution globale
	sudo touch $ROOT_DIR$1/web/app.php
	echo "<?php phpinfo();" >> $ROOT_DIR$1/web/app.php

	# Relancer Apache
	sudo service apache2 reload
fi
