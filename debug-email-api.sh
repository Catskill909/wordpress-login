#!/bin/bash

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="https://djchucks.com/tester/wp-json"
PLUGIN_PATH="wp-flutter/v1"

# Debug mode - set to true to see more detailed output
DEBUG=true

# Test emails - we'll try different formats
TEST_EMAIL_1="catskill909@yahoo.com"  # Corrected spelling from screenshot
TEST_EMAIL_2="paulhnyc@gmail.com"     # From screenshot
TEST_EMAIL_3="admin@djchucks.com"

echo -e "${YELLOW}=== WordPress API Email Debug Tool ===${NC}"
echo -e "${YELLOW}This script will test the email functionality of the WordPress API${NC}"
echo -e "${YELLOW}Available test emails:${NC}"
echo -e "${YELLOW}1. ${TEST_EMAIL_1}${NC}"
echo -e "${YELLOW}2. ${TEST_EMAIL_2}${NC}"
echo -e "${YELLOW}3. ${TEST_EMAIL_3}${NC}"
echo -e "${YELLOW}4. Enter custom email${NC}"
echo ""

# Ask which email to use
echo -e "${YELLOW}Which email would you like to test? (1-4)${NC}"
read -r email_choice

case $email_choice in
    1) TEST_EMAIL=$TEST_EMAIL_1 ;;
    2) TEST_EMAIL=$TEST_EMAIL_2 ;;
    3) TEST_EMAIL=$TEST_EMAIL_3 ;;
    4)
        echo -e "${YELLOW}Enter custom email:${NC}"
        read -r custom_email
        TEST_EMAIL=$custom_email
        ;;
    *)
        echo -e "${RED}Invalid choice. Using default: ${TEST_EMAIL_1}${NC}"
        TEST_EMAIL=$TEST_EMAIL_1
        ;;
esac

echo -e "${YELLOW}Using test email: ${TEST_EMAIL}${NC}"
echo ""

# Function to make API requests with verbose output
test_endpoint() {
    local endpoint=$1
    local data=$2
    local description=$3

    echo -e "${YELLOW}=== Testing: ${description} ===${NC}"
    echo -e "${YELLOW}Endpoint: ${endpoint}${NC}"
    echo -e "${YELLOW}Request data: ${data}${NC}"
    echo ""

    # Make the request with verbose output
    echo -e "${YELLOW}Making request...${NC}"
    response=$(curl -v -X POST "${BASE_URL}/${PLUGIN_PATH}/${endpoint}" \
        -H "Content-Type: application/json" \
        -d "${data}" 2>&1)

    # Extract the response body (last line)
    response_body=$(echo "$response" | grep -v "^*" | grep -v "^>" | grep -v "^<" | grep -v "^}" | tail -1)

    echo -e "${YELLOW}Full response:${NC}"
    echo "$response"
    echo ""

    echo -e "${YELLOW}Response body:${NC}"
    echo "$response_body"
    echo ""

    # Check if response contains success status
    if echo "$response_body" | grep -q '"status":"success"'; then
        echo -e "${GREEN}✓ Test passed${NC}"
    else
        echo -e "${RED}✗ Test failed${NC}"
    fi
    echo ""
}

# Test 1: Request password reset code
test_endpoint "request-reset-code" "{\"email\":\"${TEST_EMAIL}\"}" "Request Password Reset Code"

# Ask if user wants to test verification code
echo -e "${YELLOW}Did you receive a verification code? (y/n)${NC}"
read -r received_code

if [ "$received_code" = "y" ]; then
    echo -e "${YELLOW}Enter the verification code:${NC}"
    read -r code

    # Test 2: Verify reset code
    test_endpoint "verify-reset-code" "{\"email\":\"${TEST_EMAIL}\",\"code\":\"${code}\"}" "Verify Password Reset Code"

    # Extract reset token from response
    reset_token=$(echo "$response_body" | grep -o '"reset_token":"[^"]*"' | cut -d'"' -f4)

    if [ -n "$reset_token" ]; then
        echo -e "${YELLOW}Reset token: ${reset_token}${NC}"

        # Ask if user wants to test password reset
        echo -e "${YELLOW}Do you want to test password reset? (y/n)${NC}"
        read -r test_reset

        if [ "$test_reset" = "y" ]; then
            echo -e "${YELLOW}Enter new password:${NC}"
            read -r new_password

            # Test 3: Reset password
            test_endpoint "reset-password" "{\"email\":\"${TEST_EMAIL}\",\"reset_token\":\"${reset_token}\",\"new_password\":\"${new_password}\"}" "Reset Password"
        fi
    fi
fi

echo -e "${YELLOW}=== Debug Complete ===${NC}"
