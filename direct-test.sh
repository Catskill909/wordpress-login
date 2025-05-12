#!/bin/bash

# Direct test script to request a password reset code
echo "Testing password reset code request..."

# Define variables
EMAIL="catskill909@yahoo.com"
ENDPOINT="https://djchucks.com/tester/wp-json/wp-flutter/v1/request-reset-code"

# Print request details
echo "Sending request to: $ENDPOINT"
echo "With email: $EMAIL"

# Make the request
curl -v -X POST \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\"}" \
  "$ENDPOINT"

echo ""
echo "Request completed."
