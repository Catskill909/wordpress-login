<?php
// Test script to check if the WordPress plugin is working correctly

// Function to get a user by email
function get_user_by_email($email) {
    // This is a simplified version of the WordPress function
    // In a real WordPress environment, you would use get_user_by('email', $email)
    
    // For testing purposes, let's hardcode some users
    $users = [
        'catksill909@yahoo.com' => [
            'ID' => 1,
            'user_email' => 'catksill909@yahoo.com',
            'user_login' => 'catksill909',
        ],
        'admin@djchucks.com' => [
            'ID' => 2,
            'user_email' => 'admin@djchucks.com',
            'user_login' => 'admin',
        ],
        'login@djchucks.com' => [
            'ID' => 3,
            'user_email' => 'login@djchucks.com',
            'user_login' => 'login',
        ],
    ];
    
    // Check if the email exists in our hardcoded users
    if (isset($users[$email])) {
        return (object) $users[$email]; // Convert array to object
    }
    
    return false; // User not found
}

// Test the function with different emails
$test_emails = [
    'catksill909@yahoo.com',
    'admin@djchucks.com',
    'login@djchucks.com',
    'nonexistent@example.com',
];

foreach ($test_emails as $email) {
    $user = get_user_by_email($email);
    
    if ($user) {
        echo "User found for email '$email': ID = {$user->ID}, Login = {$user->user_login}\n";
    } else {
        echo "No user found for email '$email'\n";
    }
}

// Test with different case
$email = 'CatKsill909@yahoo.com'; // Mixed case
$user = get_user_by_email($email);

if ($user) {
    echo "User found for email '$email': ID = {$user->ID}, Login = {$user->user_login}\n";
} else {
    echo "No user found for email '$email'\n";
}

// In WordPress, get_user_by('email', $email) is case-insensitive
// Let's simulate this behavior
$email = 'CatKsill909@yahoo.com'; // Mixed case
$email_lowercase = strtolower($email);
$user = get_user_by_email($email_lowercase);

if ($user) {
    echo "User found for email '$email' (case-insensitive): ID = {$user->ID}, Login = {$user->user_login}\n";
} else {
    echo "No user found for email '$email' (case-insensitive)\n";
}
