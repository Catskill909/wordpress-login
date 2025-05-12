<?php
/**
 * Plugin Name: WordPress Flutter Custom Password Reset
 * Description: Custom password reset functionality for Flutter app integration
 * Version: 1.0
 * Author: Augment Agent
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

/**
 * Register custom REST API endpoints for password reset
 */
add_action('rest_api_init', function () {
    // Request password reset code endpoint
    register_rest_route('wp-flutter/v1', '/request-reset-code', array(
        'methods' => 'POST',
        'callback' => 'wp_flutter_request_reset_code',
        'permission_callback' => function () {
            return true; // Public endpoint
        }
    ));

    // Verify reset code endpoint
    register_rest_route('wp-flutter/v1', '/verify-reset-code', array(
        'methods' => 'POST',
        'callback' => 'wp_flutter_verify_reset_code',
        'permission_callback' => function () {
            return true; // Public endpoint
        }
    ));

    // Reset password with verified code endpoint
    register_rest_route('wp-flutter/v1', '/reset-password', array(
        'methods' => 'POST',
        'callback' => 'wp_flutter_reset_password',
        'permission_callback' => function () {
            return true; // Public endpoint
        }
    ));
});

/**
 * Generate a random verification code
 * 
 * @return string 6-digit verification code
 */
function generate_verification_code() {
    return sprintf('%06d', mt_rand(0, 999999));
}

/**
 * Request password reset code
 * 
 * @param WP_REST_Request $request Full data about the request.
 * @return WP_REST_Response
 */
function wp_flutter_request_reset_code($request) {
    $email = sanitize_email($request->get_param('email'));

    // Validate input
    if (empty($email)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Please provide an email address.'
        ), 400);
    }

    // Check if email exists
    if (!email_exists($email)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'No user found with this email address.'
        ), 400);
    }

    // Get user by email
    $user = get_user_by('email', $email);

    // Generate verification code
    $verification_code = generate_verification_code();
    
    // Store verification code in user meta with expiration time (30 minutes)
    $expiration = time() + (30 * 60); // 30 minutes from now
    update_user_meta($user->ID, 'password_reset_code', $verification_code);
    update_user_meta($user->ID, 'password_reset_code_expiration', $expiration);

    // Send verification code email
    $subject = 'Password Reset Verification Code';
    $message = 'You have requested to reset your password. Use the following verification code to complete the process: ' . $verification_code . "\n\n";
    $message .= 'This code will expire in 30 minutes.';
    
    $result = wp_mail($email, $subject, $message);

    if (!$result) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Failed to send verification code email.'
        ), 500);
    }

    return new WP_REST_Response(array(
        'status' => 'success',
        'message' => 'Verification code sent to your email.'
    ), 200);
}

/**
 * Verify reset code
 * 
 * @param WP_REST_Request $request Full data about the request.
 * @return WP_REST_Response
 */
function wp_flutter_verify_reset_code($request) {
    $email = sanitize_email($request->get_param('email'));
    $code = sanitize_text_field($request->get_param('code'));

    // Validate input
    if (empty($email) || empty($code)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Please provide both email and verification code.'
        ), 400);
    }

    // Get user by email
    $user = get_user_by('email', $email);
    if (!$user) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Invalid email address.'
        ), 400);
    }

    // Get stored verification code and expiration
    $stored_code = get_user_meta($user->ID, 'password_reset_code', true);
    $expiration = get_user_meta($user->ID, 'password_reset_code_expiration', true);

    // Check if code is valid and not expired
    if (empty($stored_code) || $stored_code !== $code) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Invalid verification code.'
        ), 400);
    }

    if (time() > $expiration) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Verification code has expired. Please request a new one.'
        ), 400);
    }

    // Generate a temporary token for password reset
    $reset_token = wp_generate_password(32, false);
    update_user_meta($user->ID, 'password_reset_token', $reset_token);
    update_user_meta($user->ID, 'password_reset_token_expiration', time() + (15 * 60)); // 15 minutes

    return new WP_REST_Response(array(
        'status' => 'success',
        'message' => 'Verification code is valid.',
        'reset_token' => $reset_token
    ), 200);
}

/**
 * Reset password with verified code
 * 
 * @param WP_REST_Request $request Full data about the request.
 * @return WP_REST_Response
 */
function wp_flutter_reset_password($request) {
    $email = sanitize_email($request->get_param('email'));
    $reset_token = sanitize_text_field($request->get_param('reset_token'));
    $new_password = $request->get_param('new_password');

    // Validate input
    if (empty($email) || empty($reset_token) || empty($new_password)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Please provide email, reset token, and new password.'
        ), 400);
    }

    // Get user by email
    $user = get_user_by('email', $email);
    if (!$user) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Invalid email address.'
        ), 400);
    }

    // Verify reset token
    $stored_token = get_user_meta($user->ID, 'password_reset_token', true);
    $expiration = get_user_meta($user->ID, 'password_reset_token_expiration', true);

    if (empty($stored_token) || $stored_token !== $reset_token) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Invalid reset token.'
        ), 400);
    }

    if (time() > $expiration) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Reset token has expired. Please restart the password reset process.'
        ), 400);
    }

    // Reset the password
    wp_set_password($new_password, $user->ID);

    // Clear reset data
    delete_user_meta($user->ID, 'password_reset_code');
    delete_user_meta($user->ID, 'password_reset_code_expiration');
    delete_user_meta($user->ID, 'password_reset_token');
    delete_user_meta($user->ID, 'password_reset_token_expiration');

    return new WP_REST_Response(array(
        'status' => 'success',
        'message' => 'Password has been reset successfully.'
    ), 200);
}
