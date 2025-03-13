#!/bin/bash

################################################################################
# Author: Darshan M
# Version: 1.0
# Purpose: 
#   - This script retrieves various AWS resources in a structured table format.
#   - The output is saved to a file and uploaded to an S3 bucket for backup.
#   - It includes debugging, error handling, and AWS CLI validation.
#
# Usage:
#   - Run this script on a Linux machine with AWS CLI installed.
#   - Ensure you have proper AWS credentials configured (`aws configure`).
#   - Update the S3_BUCKET variable with your bucket name.
#   - Execute: chmod +x aws-resource-backup.sh && ./aws-resource-backup.sh
################################################################################

# Debugging & Error Handling
set -x  # Print commands before execution (for debugging)
set -e  # Exit immediately if any command fails
set -o pipefail  # Catch errors in piped commands

# AWS CLI Check
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI."
    exit 1
fi

# AWS Credentials Check
if [ ! -d ~/.aws ]; then
    echo "AWS credentials/config not found! Run 'aws configure'."
    exit 1
fi

# Variables
S3_BUCKET="your-s3-bucket-name"  # Replace with your S3 bucket name
OUTPUT_FILE="aws-resources-$(date +%F-%H-%M-%S).txt"  # Output file with timestamp

echo "Fetching AWS resource details..." | tee $OUTPUT_FILE

# Get EC2 instances
echo -e "\n== EC2 Instances ==" | tee -a $OUTPUT_FILE
aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PublicIpAddress,PrivateIpAddress]' \
    --output table | tee -a $OUTPUT_FILE

# Get S3 Buckets
echo -e "\n== S3 Buckets ==" | tee -a $OUTPUT_FILE
aws s3api list-buckets \
    --query 'Buckets[*].[Name,CreationDate]' \
    --output table |
