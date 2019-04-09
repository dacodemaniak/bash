#!/bin/bash

##
# Création des vhosts Apache spécifique Symfony 3
# Usage :
# ./addVhost vhost_name [use_ssl]
##

sudo -v

# Définition des fonctions
function restart_apache() {
	sudo service apache2 reload
}
 
function log() {
	local log_time = $(date '+%d/%m/%Y %H:%M:%S'); 
	echo "$log_time\t$1\t$2\n" >> /var/log/apache2/addvhost.log
}

# Définit le dossier racine des applications Apache
DOCUMENT_ROOT="/home/jean-luc/www/"

if [ $# == 0 ]
then
	echo "To few arguments to process. Operation failed"
	log "To few arguments to process" -1
	exit -1
else
	# Vérifier le nombre d'arguments passés
	if [ $# == 2 ]
	then
		# Vérifier la valeur du second argument
		if [ $2 == "disable" ]
		then
			sudo a2dissite $1.conf
			restart_apache
			log "Désactivation du site $1" 0
		else
			if [ $2 == "enable" ]
			then
				sudo a2ensite $1.conf
				sudo service apache2 reload
				log "Activation du site $1" 0
			else
				if [ $2 == "remove" ]
				then
					# TODO : Demander à l'utilisateur de confirmer la suppression
					sudo a2dissite $1.conf
					sudo rm /etc/apache2/sites-available/$1.conf
					sudo rm -R $DOCUMENT_ROOT$1
					restart_apache
					log "Suppression complète du site $1" 0
				else
					echo "$2 n'est pas une option valide !"
					log "$2 n'est pas un argument valide" -1
					exit -1
				fi
			fi
		fi
	else
		# Stocker le dossier dans une variable
		DIRECTORY=$1

		# Tester l'existence du dossier
		if [! -d "$DOCUMENT_ROOT$DIRECTORY" ]
		then
			# Copier le fichier template-symfony vers /etc/apache2/sites-available
			# avec le nom vhost_name.conf
			cp ./template-symfony /etc/apache2/sites-available/$1.conf

			# Créer le dossier dans le dossier /home/jlaubert/www
			mkdir -p $DOCUMENT_ROOT$1 $DOCUMENT_ROOT$1/web

			# Remplacer "template" par "vhost_name" dans le fichier de configuration
			sudo sed -i 's/template/'$1'/g' /etc/apache2/sites-available/$1.conf

			# Ajouter le fichier de configuration à la liste des sites actifs
			sudo a2ensite $1.conf

			# Mettre à jour le fichier hosts
			echo "127.0.0.1 $1.wrk www.$1.wrk" >> /etc/hosts

			# Vérifier l'exécution globale
			sudo touch $DOCUMENT_ROOT$1/web/app.php
			echo "<?php phpinfo();" >> $DOCUMENT_ROOT$1/web/app.php

			# Relancer Apache
			restart_apache

			log "Création du vhost $1" 0
		else
			echo "Le dossier $DOUCMENT_ROOT$DIRECTORY a déjà été créé."
			log "Le dossier $1 existe déjà" -1
			exit -1
		fi
	fi
fi
