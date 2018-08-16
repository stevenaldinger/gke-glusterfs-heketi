#!/bin/sh

# simple script to sync up with wizard1024 if he's still active.
# much appreciation for the work up until now regardless.

my_collaborator_friend='wizard1024'

add_collab_remote_if_not_exists () {
  if [ ! -z "$(git remote -v | grep $my_collaborator_friend)" ]
  then
    echo "Collaborator remote already exists."
  else
    echo "Adding collaborator's remote to sync changes."

    git remote add $my_collaborator_friend git@github.com:$my_collaborator_friend/gke-glusterfs-heketi.git
  fi
}

merge_collab_remote_into_local () {
  git remote update

  git pull $my_collaborator_friend master
}

main () {
  add_collab_remote_if_not_exists
  merge_collab_remote_into_local
}

main
