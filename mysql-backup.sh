# This Bash script automates MySQL database backups, creating gzip-compressed SQL dumps for specified databases.
#The perform_mysql_backup function orchestrates the backup process, iterating through each specified database, generating a backup filename with a timestamp, and executing mysqldump to create a SQL dump, compressing it with gzip. It also checks the success of each backup operation and triggers functions to copy recent backups to a network folder and clean up old backup files.
#The copy_recent_backups_to_network function identifies recently modified backup files within the last 5 minutes and copies them to the designated network folder using samba.
#Finally, the cleanup_old_backups function removes backup files older than 7 days from the backup directory to manage storage space efficiently.

#!/bin/bash

# MySQL credentials
DB_USER=""
DB_PASS=""

# Backup directory
BACKUP_DIR=""

# List of databases to backup
DATABASES=("DB1" "DB2")

# Set the network folder where zip files will be copied
NETWORK_FOLDER="paste n/w folder path"
 
# Function for MySQL database backup
perform_mysql_backup() {
  # Ensure the backup directory exists
  mkdir -p "$BACKUP_DIR"

  # Get the current date to use in backup filenames
  DATE=$(date +%Y%m%d%H%M%S)

  # Loop through each database and create a backup
  for DB_NAME in "${DATABASES[@]}"; do
    # Generate the backup filename
    BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$DATE.sql.gz"

    # Perform the database backup using mysqldump and gzip it in one command
      mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$BACKUP_FILE"

    # Check if the backup was successful
    if [ $? -eq 0 ]; then
      echo "Backup of '$DB_NAME' completed successfully. File: $BACKUP_FILE"
    else
      echo "Backup of '$DB_NAME' failed."
    fi
  done

  echo "All database backups completed."

  # Call the function to copy recent files to the network folder
  copy_recent_backups_to_network

  # Call the cleanup function
  cleanup_old_backups
}

# Function to copy recent files to the network folder
copy_recent_backups_to_network() {
  # Find and copy backup files modified in the last 5 minutes
  recent_files=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.sql.gz" -mmin -5)

  if [ -n "$recent_files" ]; then
    for file in $recent_files; do
      cp "$file" "$NETWORK_FOLDER"
      echo "Copied $file to the network folder."
    done
  else
    echo "No new backup files found in the last 5 minutes."
  fi
}

# Function for cleanup - remove files older than 7 days
cleanup_old_backups() {
  # Find and remove files older than 7 days in the backup directory
  find "$BACKUP_DIR" -type f -mtime +7 -name "*.sql.gz" -exec rm {} \;
  echo "Old backup files older than 7 days removed."
}

# Execute the backup function
perform_mysql_backup
