#!/bin/bash 

filename=/etc/Phonebook/phonebookDB.txt
if [ -e $filename ]
then
 echo "File phonebookDB.txt already exists!"
else
 echo >> "$filename" 
fi

#check how many contacts are saved in the phonebook
temp=/etc/Phonebook/counter.dat
if [ ! -f $temp ]
then
 echo >> "$temp" 
 counter=0
 echo "${counter}" > $temp
else 
 counter=`sudo cat /etc/Phonebook/counter.dat`
fi

#switching on the option entered by the user
option=$1
case "${option}" in 
-i)
 counter=`sudo cat /etc/Phonebook/counter.dat`
 counter=$((counter+1))
 echo "${counter}" > $temp
 echo "Enter the name of the contact : "
 read name 
 echo "Enter phone number : "
 read phone
 printf "$counter. Name : $name \n" >> "$filename" 
 printf "   Phone Number : $phone \n" >> "$filename"
 printf "                      \n"  >> "$filename"
;;

-v)
 if [ -s $filename ]
 then
  cat /etc/Phonebook/phonebookDB.txt 
 else 
  echo "your contact list is empty"
 fi 
;;

-s)
 echo "Please enter the name you want to search for : "
 read search_name
 cmd=$(grep -ic "$search_name" $filename)
 if [ "$cmd" != "0" ] 
 then 
   grep -A 1 "$search_name" $filename
 else 
  echo This name is not saved in you contact list
 fi
 ;;

-e) 
 cat /dev/null > $filename
 counter=0
 echo "${counter}" > $temp
 
 ;;

-d)
 echo "please enter the name you wish to delete : "
 read delete_name
 wordRepeats=$(grep -ic "$delete_name" $filename) 
 if  [ "$wordRepeats" -gt 1 ]
 then
  echo "There are $wordRepeats contacts with the same name, which one do you wish to delete ?"
  grep -i "$delete_name" $filename
  echo "please enter the index corresponding to the name you wish to delete exactly as displayed above : "
  read name_index
  sed --in-place "/^$name_index/, +1 d" $filename
  sed '/^$/d' $filename
 else
  sed --in-place "/$delete_name/, +1 d" $filename
  sed '/^$/d' $filename
 fi
 echo "Name deleted successfully!"
 counter=sudo cat /etc/Phonebook/counter.dat
 updated_names_number=$((counter-name_index))

#updating contacts index 
 while [ " $updated_names_number" -gt 0 ]
 do
  next_str_index=$((name_index+1))
  sed -i "s/${next_str_index}/${name_index}/" $filename
  name_index=$((name_index+1))
  updated_names_number=$((updated_names_number-1))
 done

 counter=$((counter-1))
 echo "${counter}" > $temp 
 
;;

*) 
 echo "You have not entered a valid option, please try again with one of the following :\n"
 printf "for inserting a new contact, press -i \n"
 printf "to view all saved contacts, press -v \n"
 printf "to search a contact by it's name, press -s \n"
 printf "to delete all records, press -e \n"
 printf "to delete a certain record, press -d \n"
;;

esac   
