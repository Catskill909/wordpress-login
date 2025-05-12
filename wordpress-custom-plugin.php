<?php
/**
 * Plugin Name: WordPress Flutter Auth
 * Plugin URI: https://github.com/Catskill909/wordpress-login
 * Description: Custom authentication endpoints for Flutter app
 * Version: 1.0.0
 * Author: Catskill909
 * Author URI: https://github.com/Catskill909
 * License: GPL2
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

/**
 * Register custom REST API endpoints for authentication
 */
add_action('rest_api_init', function () {
    // Register user endpoint
    register_rest_route('wp/v2/users', '/register', array(
        'methods' => 'POST',
        'callback' => 'wp_flutter_register_user',
        'permission_callback' => function () {
            return true; // Public endpoint
        }
    ));

    // Password reset endpoint
    register_rest_route('wp/v2/users', '/lostpassword', array(
        'methods' => 'POST',
        'callback' => 'wp_flutter_reset_password',
        'permission_callback' => function () {
            return true; // Public endpoint
        }
    ));
});

/**
 * Register a new user
 * 
 * @param WP_REST_Request $request Full data about the request.
 * @return WP_REST_Response
 */
function wp_flutter_register_user($request) {
    $username = sanitize_user($request->get_param('username'));
    $email = sanitize_email($request->get_param('email'));
    $password = $request->get_param('password');
    $display_name = sanitize_text_field($request->get_param('name') ?: $username);

    // Validate input
    if (empty($username) || empty($email) || empty($password)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Please provide username, email, and password.'
        ), 400);
    }

    // Check if username exists
    if (username_exists($username)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Username already exists.'
        ), 400);
    }

    // Check if email exists
    if (email_exists($email)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Email already exists.'
        ), 400);
    }

    // Create user
    $user_id = wp_create_user($username, $password, $email);

    if (is_wp_error($user_id)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => $user_id->get_error_message()
        ), 400);
    }

    // Update display name
    wp_update_user(array(
        'ID' => $user_id,
        'display_name' => $display_name
    ));

    // Set user role
    $user = new WP_User($user_id);
    $user->set_role('subscriber');

    // Send notification email
    wp_new_user_notification($user_id, null, 'both');

    // Get user data
    $user_data = get_userdata($user_id);

    // Return success response
    return new WP_REST_Response(array(
        'status' => 'success',
        'message' => 'User registered successfully.',
        'user' => array(
            'id' => $user_id,
            'username' => $user_data->user_login,
            'email' => $user_data->user_email,
            'display_name' => $user_data->display_name
        )
    ), 201);
}

/**
 * Reset user password
 * 
 * @param WP_REST_Request $request Full data about the request.
 * @return WP_REST_Response
 */
function wp_flutter_reset_password($request) {
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

    // Generate reset key
    $key = get_password_reset_key($user);

    if (is_wp_error($key)) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => $key->get_error_message()
        ), 500);
    }

    // Send password reset email
    $result = wp_mail(
        $email,
        'Password Reset',
        'Someone has requested a password reset for your account. If this was you, click the link below to reset your password: ' . 
        network_site_url("wp-login.php?action=rp&key=$key&login=" . rawurlencode($user->user_login), 'login')
    );

    if (!$result) {
        return new WP_REST_Response(array(
            'status' => 'error',
            'message' => 'Failed to send password reset email.'
        ), 500);
    }

    // Return success response
    return new WP_REST_Response(array(
        'status' => 'success',
        'message' => 'Password reset email sent successfully.'
    ), 200);
}
