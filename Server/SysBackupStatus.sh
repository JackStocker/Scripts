#!/bin/sh
# Full System Backup status check script

MESSAGE=

MESSAGE+="------------------------------------------------------\n"
MESSAGE+="- System Backup Status Check - $(date) -\n"
MESSAGE+="------------------------------------------------------\n"
MESSAGE+="\n"

cd /media/RAID/Server/

WORKING_DIRECTORY=`pwd`

# Check whether RAID SysBackup folder exists
if [ $WORKING_DIRECTORY != "/media/RAID/Server" ]; then
 MESSAGE+="ERROR. CD failed to find RAID, exiting backup check.\n"

 echo -e "$MESSAGE"
 exit
fi

MESSAGE+="-----File Summary-----\n"
MESSAGE+="\n"
MESSAGE+="      File name      | Creation date | Size |  Age  \n"

CUR_DATE=`date`
LATEST_FILE_AGE=( )
PERCENT_DIFF=( )
ALL_DELETED_FILES=( )

# For each file in the Server System Backup directory
OLDER_FILE_AGE=
OLDER_TOTAL_SIZE=
NEWER_FILE_AGE=
NEWER_TOTAL_SIZE=
CUR_FILE_AGE=
CUR_FILE_SIZE=
F_LATEST_FILE_AGE=


# Get a list of all the file names in asending cronological order. Only retrieve the 3rd and onwards rows (i.e. always keep the two latest backups)
DELETED_FILES=( `find . -name 'SysBackup_*.tgz' -printf "%T@ %p\n" | sort -rn | tail -n +3 | sed -r 's/^.{22}//'` )

if [ "${#DELETED_FILES[@]}" -gt 0 ]; then
 for del_file in "${DELETED_FILES[@]}"; do
  ALL_DELETED_FILES=( "${ALL_DELETED_FILES[@]}" "$del_file" )

  rm $del_file
 done
fi


# For each file in the folder, find the name, date and size
for file in *; do
 [ -f "$file" ] || continue

 FILE_NAME=$file

#   echo "File: "$file

 FILE_NAME_SHORT=`echo ${FILE_NAME} | cut -c1-12`
 FILE_EXT=`echo ${FILE_NAME} | sed 's/.*\(\..*\)/\1/'`
 FILE_NAME=${FILE_NAME_SHORT}${FILE_EXT}

 FILE_DATE=`stat -c %y "$file" | cut -d ' ' -f1`
 FILE_SIZE=`stat -c %s "$file"`
 DISPLAY_FILE_SIZE=$(ls -lah "$file" | awk '{ print $5}')
 DISPLAY_FILE_SIZe="$DISPLAY_FILE_SIZE$BYTE"
 FILE_AGE=$(( ( $(date +%s) - $(date -d "$FILE_DATE" +%s) ) /(24 * 60 * 60 ) ))

 if [ -z "$F_LATEST_FILE_AGE" ]; then
   F_LATEST_FILE_AGE=$FILE_AGE
 else
  if [ $FILE_AGE -lt $F_LATEST_FILE_AGE ]; then
   F_LATEST_FILE_AGE=$FILE_AGE
  fi
 fi

 MESSAGE+=$(printf "%-21s %-15s %-6s %-3s days\n" "$FILE_NAME" \
		                         	  "$FILE_DATE" \
			                      	  "$DISPLAY_FILE_SIZE"B \
				              	  "$FILE_AGE")"\n"

 # Use the current file
 CUR_FILE_AGE=$FILE_AGE
 CUR_FILE_SIZE=$FILE_SIZE

 # Find the latest and second latest backup sets and add up their size
 if [ -z "$NEWER_FILE_AGE" ]; then
  NEWER_FILE_AGE=$CUR_FILE_AGE
  NEWER_TOTAL_SIZE=$CUR_FILE_SIZE
 else
  if [ $CUR_FILE_AGE -gt $(($NEWER_FILE_AGE -1)) ]; then
   if [ -z "$OLDER_FILE_AGE" ]; then
    OLDER_FILE_AGE=$CUR_FILE_AGE
    OLDER_TOTAL_SIZE=$CUR_FILE_SIZE
   else
    if [ $CUR_FILE_AGE -lt $(($OLDER_FILE_AGE +1)) ]; then
     OLDER_FILE_AGE=$CUR_FILE_AGE
     OLDER_TOTAL_SIZE=$CUR_FILE_SIZE
    else
     if [ $CUR_FILE_AGE -gt $(($OLDER_FILE_AGE +1)) ]; then
      OLDER_TOTAL_SIZE=$(($OLDER_TOTAL_SIZE + $CUR_FILE_SIZE))
     fi
    fi
   fi
  else
   if [ $CUR_FILE_AGE -lt $(($NEWER_FILE_AGE +1)) ]; then
    NEWER_TOTAL_SIZE=$(($NEWER_TOTAL_SIZE + $CUR_FILE_SIZE))
   else
    OLDER_FILE_AGE=$NEWER_FILE_AGE
    OLDER_TOTAL_SIZE=$NEWER_TOTAL_SIZE

    NEWER_FILE_AGE=$CUR_FILE_AGE
    NEWER_TOTAL_SIZE=$CUR_FILE_SIZE
   fi
  fi
 fi

done


MESSAGE+="\n"
MESSAGE+="\n"
MESSAGE+="-----Deleted File Summary-----\n"
MESSAGE+="\n"

for deleted_file in "${ALL_DELETED_FILES[@]}"; do
 MESSAGE+="$deleted_file"
 MESSAGE+="\n"
done
