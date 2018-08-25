#!/bin/bash
#Example: ./rename.sh file-directory-list.txt <file-to-replace> <replacement-file>
file_directory_list=$1
target_file_name=$2
replcement_file_name=$3
relativePath="$(cd "$(dirname "$1")"; pwd)/"
current_directory_name=${PWD##*/} #gets the name of the directory that you are in

function init() { 
  renameFile
}

function renameFile() { 
  totalFileCount=0;
  if [[ -f file_replace_error.log ]];
  then
    rm  file_replace_error.log;
  fi
  
  if [[ -f file_replace_success.log ]];
  then
    rm file_replace_success.log;
  fi
  touch file_replace_success.log;
  
  if [[ -f $file_directory_list ]];
  then
    for line in $( <$file_directory_list );
    do
      fspec=$relativePath$line; #The full path of the file 
      #filename="${fspec##*/}";  # get filename
      dir_name="${fspec%/*}"; #get directory/path name
      root_folder="${fspec#*/*}"; #get directory/path name
      if [[ -d $line ]];
      then 
        for file in $dir_name/*.*;
        do
          if [[ $file =~ $target_file_name ]];
          then
            mkdir -p $dir_name/original_$target_file_name; #-p checks if the directory exists
            if [[ -f $file ]]; #if the match is a file
            then 
              echo "Found a match! $file";
              cp $file $dir_name/original_$target_file_name;
              rm $file && cp $replcement_file_name $dir_name;
              echo "Replaced file with: $dir_name/$replcement_file_name" >> file_replace_success.log
              totalFileCount=`expr $totalFileCount + 1`;
            fi
          fi
        done
        wait
      else
        touch file_replace_error.log;
        echo "The Directory chosen does not exist: $dir_name";
        echo "The Directory chosen does not exist: $dir_name" >> file_replace_error.log;
      fi
    done 
    echo "Total Files replaced: $totalFileCount";
  fi
}

init