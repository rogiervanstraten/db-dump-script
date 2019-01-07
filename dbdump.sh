#!/bin/bash
# v0.1
# Import helper functions
source ./helpers.sh

# import config files
config_file=./.config

# -----------------------------------------------------------------
# Requirements check
# -----------------------------------------------------------------

if [ ! -f "$config_file" ]; then
  echo ".config file does not exist"
  exit 1
fi

# We include the config file
source $config_file

# check if requirements are installed 
if ! file_exists mysqldump; then
  echo "Mysqldump is a required function"
  exit 1
fi

if ! file_exists openssl; then
  echo "Openssl is a required function for encrypting"
  exit 1
fi

if [ ! -d "$target_dir" ]; then
  echo "The target directory doesn't exists..."
  exit 1
fi

# -----------------------------------------------------------------
# Start script
# -----------------------------------------------------------------

file_date=$(date +%s)
db_file_path=$target_dir$file_prefix$file_date
tmp_file=./tmp/$file_prefix$file_date.sql
tar_file=./tmp/$file_prefix$file_date.tar

# run db dump
mysqldump -u${db_user} -p${db_password} $db_name > $tmp_file
tar cvf $tar_file $tmp_file

# check if we want to encrypt the file
if $crypt;
  then
    # zip -r -0 -e $file_prefix$file_date.sql.zip ./tmp/$file_prefix$file_date.sql
    openssl aes-128-cbc -salt -in $tar_file -out ${tar_file}.aes -k $crypt_key
    if [ -f "$tar_file" ]; then rm -f $tar_file; fi
fi

# Remove tmp file
if [ -f "$tmp_file" ]; then rm -f $tmp_file; fi
