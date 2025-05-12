#!/bin/bash

# Simple test script to request a password reset code
echo "Testing password reset code request..."
curl -v -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"catskill909@yahoo.com"}' \
  https://djchucks.com/tester/wp-json/wp-flutter/v1/request-reset-code
