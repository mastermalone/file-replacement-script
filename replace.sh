#!/bin/bash
#Example: ./rename.sh <-R (replace) or -r (reverse the previous replacement)>file-directory-list.txt then follow the prompts
file_directory_list=$2
#target_file_name=${2?Error: No target file provided}
#replcement_file_name=${3?Error: No replacement file provided}
relativePath="$(cd "$(dirname "$2")"; pwd)/"
current_directory_name=${PWD##*/} #gets the name of the directory that you are in
replaceFile=false;

  
#Begin Main functionality
function getDirectoryListAndSetFileVariableValues() { 
  read -p "Provide the name of the file you wish to replace: " target_file_name;
  read -p "Provide the name of the replacement file: " replcement_file_name;
  
  if [[ -z $file_directory_list || -z $target_file_name || -z $replcement_file_name ]];
  then
    echo "You did not provide information for one of the previously requested files."; 
  else
    
    if [[ -f $replcement_file_name ]];
    then
      if ! ( $replaceFile );
      then 
        reverseReplacement
      else
        echo "Begin replacment.."; 
        replaceFile
      fi
      #replaceFile
    else
      echo "The file you listed as the replacement is not a file or does not exist."
    fi
  fi
}

function replaceFile() { 
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

function reverseReplacement() {
  #loop through file list
  #check for the original_<replacement_file_name> directory
  #check for the file name
  #if the file exists, delete the replacement file and..
  #copy the original file and place it back where the original was
  #delete the original_<replacement_file_name> directory and its contents
  totalReversals=0;
  if [[ -f reverse_replacement_error.log ]];
  then
    rm reverse_replacement_error.log;
  fi
  
  if [[ -f reverse_replacement_error.log ]];
  then
    rm reverse_replacement_success.log;
  fi
  
  if [[ -f $file_directory_list ]];
  then 
    #loop
    for line in $( <$file_directory_list );
    do
      fspec=$relativePath$line; #The full path of the file 
      dir_name="${fspec%/*}"; #get directory/path name
      root_folder="${fspec#*/*}"; #get directory/path name
      if [[ -d $dir_name/original_$target_file_name ]];
      then
        printf "Found the original_$target_file_name directory\n";
        if [[ -f $dir_name/original_$target_file_name/$target_file_name ]];
        then
          rm $dir_name/$replcement_file_name;
          cp $dir_name/original_$target_file_name/$target_file_name $dir_name;
          rm -rf $dir_name/original_$target_file_name;
          touch reverse_replacement_success.log;
          echo "Removed the replacement file and put the original file, $dir_name/$target_file_name, back.";
          echo "Removed the replacement file and put the original file, $dir_name/$target_file_name, back." >> reverse_replacement_success.log;
          totalReversals=`expr $totalReversals + 1`;
        fi
      else
        touch reverse_replacement_error.log;
        echo "The directory in the list does not exist here: $dir_name/original_$target_file_name";
        echo "The directory in the list does not exist here: $dir_name/original_$target_file_name" >> reverse_replacement_error.log;
      fi
    done
    echo "Total number of reversals: "$totalReversals;
  else
    touch reverse_replacement_error.log;
    echo "The directories list .txt file you have chosen does not exist"; 
    echo "The directories list .txt file you have chosen does not exist" >> reverse_replacement_error.log;
  fi
}


function usage() { 
  echo "Usage : $0 [-R <filepath.txt> 'Replaces the file'][-r <filepath.txt> 'Reverses the replacement if you already did one.']";
}

function init() { 
  getDirectoryListAndSetFileVariableValues
}

#Check options for replace or reverse and help.  This while loop for the getops cannot be inside of a function!!
while getopts R:r:h param ;
  do    
    case $param in 
      R)
        echo "Ready to replace the file? Provide the file information. Provide the file information below:";
        replaceFile=true;
        init
        exit
        ;;
        
      r)
        echo "Ready to reverse the file replacement?. Provide the file information below:";
        replaceFile=false;
        init
        exit
        ;;
        
      h)
        echo "Setting the -h flag for Help"
        usage
        exit
        ;;
        
      *)
        usage
        echo "Invalid Argument"
        exit
        ;;
    esac
  done

#init