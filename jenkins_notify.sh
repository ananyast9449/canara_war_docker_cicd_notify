#!/bin/bash

# Args: status, job, build, recipient
STATUS="$1"
JOB="$2"
BUILD="$3"
TO="$4"

# Read from Jenkins env vars
GMAIL_USER="$GMAIL_USER"
GMAIL_PASS="$GMAIL_APP_PASS"

CONFIG_FILE="/tmp/.msmtprc"

cat > $CONFIG_FILE <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account gmail
host smtp.gmail.com
port 587
from $GMAIL_USER
user $GMAIL_USER
password $GMAIL_PASS

account default : gmail
EOF

chmod 600 $CONFIG_FILE

# Email formatting
if [ "$STATUS" == "success" ]; then
    SUBJECT="✅ Jenkins Build Success: $JOB #$BUILD"
    MESSAGE="✅ Build Success\nJob: $JOB\nBuild ID: $BUILD\n\nJenkins Notification Service"
else
    SUBJECT="❌ Jenkins Build Failed: $JOB #$BUILD"
    MESSAGE="❌ Build Failed\nJob: $JOB\nBuild ID: $BUILD\n\nCheck Jenkins logs"
fi

echo -e "Subject: $SUBJECT\n\n$MESSAGE" | msmtp --file=$CONFIG_FILE "$TO"
