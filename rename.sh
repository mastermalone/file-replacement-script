#!/bin/bash

file_directory_list=$1
target_file_name=$2
replcement_file_name=$3
relativePath="$(cd "$(dirname "$1")"; pwd)/"

function init() { 
  renameFile
}

function renameFile() { 
  totalFileCount=0;
  
  if [[ -f $file_directory_list ]];
  then
    for line in $( <$file_directory_list );
    do
      fspec=$relativePath$line; #The full path of the file 
      filename="${fspec##*/}";  # get filename
      dir_name="${fspec%/*}"; #get directory/path name
      #echo $dir_name $filename;
      for file in $dir_name/*.*;
      do
        if [[ $file =~ $target_file_name ]];
        then
          echo "Found a match $file";
          echo "dirname $dir_name/$replcement_file_name";
          mv $file $dir_name/$replcement_file_name
          totalFileCount=`expr $totalFileCount + 1`;
        fi
        #echo $file;
      done
      wait
    done 
    echo "Total Files renamed $totalFileCount";
  fi
}

init