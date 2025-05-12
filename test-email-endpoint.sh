#!/bin/bash

# Test the password reset code request endpoint
echo "Testing password reset code request endpoint..."
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@djchucks.com"}' \
  https://djchucks.com/tester/wp-json/wp-flutter/v1/request-reset-code
