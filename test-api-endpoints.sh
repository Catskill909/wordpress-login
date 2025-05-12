#!/bin/bash

# Test script for WordPress Flutter Auth API endpoints
# This script tests the custom plugin endpoints for password reset and registration verification

# Base URL
BASE_URL="https://djchucks.com/tester/wp-json/wp-flutter/v1"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Test email (replace with your test email)
TEST_EMAIL="catksill909@yahoo.com"

# Function to make API requests
make_request() {
    local endpoint=$1
    local data=$2
    local method=${3:-POST}
    
    echo -e "${YELLOW}Testing endpoint: $endpoint${NC}"
    echo -e "${YELLOW}Request data: $data${NC}"
    
    response=$(curl -s -X $method "$BASE_URL/$endpoint" \
        -H "Content-Type: application/json" \
        -d "$data")
    
    echo -e "${YELLOW}Response: $response${NC}"
    
    # Check if response contains success status
    if echo "$response" | grep -q '"status":"success"'; then
        echo -e "${GREEN}✓ Test passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Test failed${NC}"
        return 1
    fi
}

# Test 1: Request password reset code
test_request_reset_code() {
    echo -e "\n${YELLOW}=== Test 1: Request Password Reset Code ===${NC}"
    make_request "request-reset-code" "{\"email\":\"$TEST_EMAIL\"}"
}

# Test 2: Verify reset code (manual input required)
test_verify_reset_code() {
    echo -e "\n${YELLOW}=== Test 2: Verify Password Reset Code ===${NC}"
    echo -e "${YELLOW}Please check your email and enter the verification code:${NC}"
    read -r code
    
    make_request "verify-reset-code" "{\"email\":\"$TEST_EMAIL\",\"code\":\"$code\"}"
    
    # Save reset token for next test
    reset_token=$(echo "$response" | grep -o '"reset_token":"[^"]*"' | cut -d'"' -f4)
    echo -e "${YELLOW}Reset token: $reset_token${NC}"
    
    return $?
}

# Test 3: Reset password
test_reset_password() {
    echo -e "\n${YELLOW}=== Test 3: Reset Password ===${NC}"
    
    if [ -z "$reset_token" ]; then
        echo -e "${RED}No reset token available. Skipping test.${NC}"
        return 1
    fi
    
    # New password
    new_password="newpassword123"
    
    make_request "reset-password" "{\"email\":\"$TEST_EMAIL\",\"reset_token\":\"$reset_token\",\"new_password\":\"$new_password\"}"
    
    return $?
}

# Test 4: Request registration verification code
test_request_registration_code() {
    echo -e "\n${YELLOW}=== Test 4: Request Registration Verification Code ===${NC}"
    make_request "request-registration-code" "{\"email\":\"$TEST_EMAIL\"}"
}

# Test 5: Verify registration code (manual input required)
test_verify_registration() {
    echo -e "\n${YELLOW}=== Test 5: Verify Registration Code ===${NC}"
    echo -e "${YELLOW}Please check your email and enter the verification code:${NC}"
    read -r code
    
    make_request "verify-registration" "{\"email\":\"$TEST_EMAIL\",\"code\":\"$code\"}"
    
    return $?
}

# Main function
main() {
    echo -e "${YELLOW}Starting API endpoint tests...${NC}"
    
    # Ask which test to run
    echo -e "\n${YELLOW}Select a test to run:${NC}"
    echo "1. Test password reset code request"
    echo "2. Test password reset code verification"
    echo "3. Test password reset"
    echo "4. Test registration code request"
    echo "5. Test registration code verification"
    echo "6. Run all tests in sequence"
    echo "0. Exit"
    
    read -r choice
    
    case $choice in
        1) test_request_reset_code ;;
        2) test_verify_reset_code ;;
        3) test_reset_password ;;
        4) test_request_registration_code ;;
        5) test_verify_registration ;;
        6)
            test_request_reset_code
            test_verify_reset_code
            test_reset_password
            test_request_registration_code
            test_verify_registration
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
}

# Run the main function
main
