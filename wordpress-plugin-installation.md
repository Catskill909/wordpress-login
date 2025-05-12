# WordPress Flutter Auth Plugin Installation Guide

This guide provides instructions for installing and configuring the WordPress Flutter Auth plugin, which adds custom REST API endpoints for user registration and password reset in your Flutter app.

## 1. Plugin Installation

### 1.1 Manual Installation

1. Download the `wordpress-custom-plugin.php` file from this repository
2. Connect to your WordPress site via FTP or file manager
3. Navigate to the `wp-content/plugins` directory
4. Create a new folder called `wordpress-flutter-auth`
5. Upload the `wordpress-custom-plugin.php` file to this folder and rename it to `wordpress-flutter-auth.php`
6. Log in to your WordPress admin dashboard
7. Go to Plugins > Installed Plugins
8. Find "WordPress Flutter Auth" in the list and click "Activate"

### 1.2 Alternative Installation

If you prefer, you can create the plugin directly on your server:

1. Log in to your WordPress site via FTP or file manager
2. Navigate to the `wp-content/plugins` directory
3. Create a new folder called `wordpress-flutter-auth`
4. Create a new file called `wordpress-flutter-auth.php` in this folder
5. Copy and paste the contents of the `wordpress-custom-plugin.php` file into this new file
6. Save the file
7. Log in to your WordPress admin dashboard
8. Go to Plugins > Installed Plugins
9. Find "WordPress Flutter Auth" in the list and click "Activate"

## 2. Testing the Plugin

After installing and activating the plugin, you should test the new endpoints to ensure they're working correctly.

### 2.1 Test User Registration Endpoint

Use a tool like Postman, ReqBin, or curl to test the registration endpoint:

```
POST https://your-wordpress-site.com/wp-json/wp/v2/users/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "securepassword123",
  "name": "Test User"
}
```

If successful, you should receive a response like:

```json
{
  "status": "success",
  "message": "User registered successfully.",
  "user": {
    "id": 123,
    "username": "testuser",
    "email": "test@example.com",
    "display_name": "Test User"
  }
}
```

### 2.2 Test Password Reset Endpoint

Use a tool like Postman, ReqBin, or curl to test the password reset endpoint:

```
POST https://your-wordpress-site.com/wp-json/wp/v2/users/lostpassword
Content-Type: application/json

{
  "email": "test@example.com"
}
```

If successful, you should receive a response like:

```json
{
  "status": "success",
  "message": "Password reset email sent successfully."
}
```

## 3. Troubleshooting

### 3.1 Endpoint Not Found (404)

If you receive a 404 error when trying to access the endpoints:

1. Make sure the plugin is activated
2. Go to Settings > Permalinks and click "Save Changes" to flush the rewrite rules
3. Check if your WordPress installation has pretty permalinks enabled

### 3.2 Permission Issues

If you receive permission errors:

1. Make sure your WordPress installation allows user registration (Settings > General > Membership)
2. Check if your server has proper file permissions for the plugin directory

### 3.3 Email Issues

If password reset emails are not being sent:

1. Make sure your WordPress installation is configured to send emails
2. Consider installing a plugin like WP Mail SMTP to improve email deliverability

## 4. Security Considerations

This plugin creates public endpoints for user registration and password reset. To enhance security:

1. Consider adding rate limiting to prevent abuse
2. Implement CAPTCHA or other anti-spam measures
3. Keep WordPress and all plugins updated
4. Use a security plugin like Wordfence to monitor and protect your site

## 5. Next Steps

After installing and testing the plugin, you can:

1. Customize the email templates for registration and password reset
2. Add additional validation for usernames, emails, and passwords
3. Extend the plugin with additional functionality as needed
