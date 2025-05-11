# WordPress and DirectAdmin Configuration Guide

This guide provides step-by-step instructions for configuring WordPress plugins and DirectAdmin email settings for integration with a Flutter mobile application.

## Table of Contents

1. [JWT Authentication Configuration](#1-jwt-authentication-configuration)
2. [DirectAdmin Email Configuration with WP Mail SMTP](#2-directadmin-email-configuration-with-wp-mail-smtp)
3. [Custom Post Types and REST API Configuration](#3-custom-post-types-and-rest-api-configuration)
4. [WordPress Security Configuration](#4-wordpress-security-configuration)
5. [Testing the Configuration](#5-testing-the-configuration)
6. [Troubleshooting](#6-troubleshooting)

## 1. JWT Authentication Configuration

The JWT Authentication plugin requires manual configuration in WordPress core files to function properly.

### 1.1 Generate a Secret Key

1. Visit [WordPress Salt Generator](https://api.wordpress.org/secret-key/1.1/salt/)
2. Copy one of the generated keys (any of them will work)

### 1.2 Edit wp-config.php

1. Access your WordPress site files via FTP or file manager
2. Locate and open the `wp-config.php` file in the root directory
3. Add the following lines before the "That's all, stop editing!" comment:

```php
/**
 * JWT Authentication configuration
 */
define('JWT_AUTH_SECRET_KEY', 'your-generated-secret-key-here');
define('JWT_AUTH_CORS_ENABLE', true);
```

### 1.3 Configure CORS Support in .htaccess

1. Access your WordPress root directory
2. Open the `.htaccess` file (or create it if it doesn't exist)
3. Add the following code at the end of the file:

```
# JWT Authentication CORS configuration
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{HTTP:Authorization} ^(.*)
RewriteRule ^(.*) - [E=HTTP_AUTHORIZATION:%1]
SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1

Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "POST, GET, OPTIONS, PUT, DELETE"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
</IfModule>
```

### 1.4 Verify Plugin Activation

1. In WordPress admin, go to Plugins
2. Ensure "JWT Authentication for WP REST API" is activated
3. If not, activate it

### 1.5 Test JWT Authentication ✅

1. Use a tool like Postman, ReqBin, or another API testing tool to test the authentication endpoint
2. Send a POST request to `https://your-wordpress-site.com/wp-json/jwt-auth/v1/token`
3. Include the following JSON body:

```json
{
  "username": "your-admin-username",
  "password": "your-admin-password"
}
```

4. You should receive a response with a token if configured correctly:

```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_email": "your-email@example.com",
  "user_nicename": "admin",
  "user_display_name": "Admin"
}
```

**Status: TESTED AND WORKING** ✅ - JWT Authentication has been successfully tested and is functioning correctly.

## 2. DirectAdmin Email Configuration with WP Mail SMTP

### 2.1 Create Email Account in DirectAdmin

1. Log in to your DirectAdmin control panel
2. Navigate to Email Accounts
3. Create a new email account:
   - Username: Choose a name (e.g., `noreply` or `app`)
   - Domain: Select your domain
   - Password: Create a strong password
   - Quota: Set as needed (e.g., 250MB)
4. Click "Create" to create the account

### 2.2 Configure WP Mail SMTP Plugin

1. In WordPress admin, go to WP Mail SMTP > Settings
2. Configure the "Mail" section:
   - From Email: Enter your DirectAdmin email (e.g., `noreply@yourdomain.com`)
   - From Name: Enter your app or site name
   - Force From Email: Enable this option
   - Force From Name: Enable this option

3. In the "Mailer" section:
   - Select "Other SMTP" as the mailer

4. Configure SMTP settings:
   - SMTP Host: `mail.yourdomain.com` (replace with your actual mail server)
   - SMTP Port: `587` (for TLS) or `465` (for SSL)
   - Encryption: Select `TLS` or `SSL` (depending on your mail server)
   - Authentication: Set to `ON`
   - Username: Your full email address (e.g., `noreply@yourdomain.com`)
   - Password: Your email account password

5. Save Settings

### 2.3 Test Email Configuration ⚠️

1. Scroll down to the "Email Test" section
2. Enter a test email address (your personal email)
3. Click "Send Email"
4. Check if you receive the test email
5. If successful, you'll see a success message

**Status: PARTIALLY WORKING** ⚠️ - WP Mail SMTP reports successful sending but emails are not being received. See troubleshooting section below.

### 2.4 Email Troubleshooting

If WP Mail SMTP reports that emails are sent successfully but you're not receiving them:

1. **Check Spam/Junk Folder**: Emails may be filtered as spam, especially for new configurations
2. **Verify Email Server Settings**:
   - Confirm the SMTP host is correct (usually mail.yourdomain.com)
   - Verify the port (587 for TLS, 465 for SSL)
   - Double-check username (full email address) and password
3. **Email Deliverability**:
   - Check if your domain has proper SPF, DKIM, and DMARC records
   - Add these DNS records in DirectAdmin if missing
4. **Server Restrictions**:
   - Some hosting providers block outgoing SMTP traffic
   - Check if your hosting provider allows outgoing SMTP on the configured port
5. **Test with Different Email**:
   - Try sending to a different email address (Gmail, Outlook, etc.)
6. **Check DirectAdmin Logs**:
   - Log into DirectAdmin and check mail logs for delivery errors

## 3. Custom Post Types and REST API Configuration

### 3.1 Create Custom Post Types

1. In WordPress admin, go to CPT UI > Add New Post Type
2. Configure the post type:
   - Post Type Slug: `app_content` (or your preferred name)
   - Plural Label: `App Contents`
   - Singular Label: `App Content`
3. Under "Additional Labels", fill in the required fields
4. Under "Settings":
   - Public: Set to `True`
   - Show in REST API: Set to `True` (important!)
   - REST API Base Slug: Leave as default or customize
5. Click "Add Post Type"

### 3.2 Configure Advanced Custom Fields

1. Go to Custom Fields > Add New
2. Name your field group (e.g., "App Content Fields")
3. Add fields as needed for your app content
4. Under "Location", set rules to show fields for your custom post type
5. Under "Settings":
   - Style: Select your preferred style
   - Position: Select position on edit screen
6. Save the field group

### 3.3 Enable ACF Fields in REST API

1. Go to Custom Fields > Field Groups
2. Edit your field group
3. For each field, click to edit and check "Show in REST API"
4. Save the field group

### 3.4 Create Custom API Endpoints (Optional)

If you need custom endpoints beyond what the REST API provides:

1. Create a new file in your theme directory or in a custom plugin
2. Add the following code (customize as needed):

```php
<?php
// Add this to functions.php or a custom plugin file

add_action('rest_api_init', function () {
  register_rest_route('app/v1', '/content', [
    'methods' => 'GET',
    'callback' => 'get_app_content',
    'permission_callback' => function () {
      return current_user_can('read');
    }
  ]);
});

function get_app_content($request) {
  $args = [
    'post_type' => 'app_content',
    'posts_per_page' => $request->get_param('per_page') ?: 10,
    'paged' => $request->get_param('page') ?: 1,
  ];

  $posts = get_posts($args);
  $data = [];

  foreach ($posts as $post) {
    $data[] = [
      'id' => $post->ID,
      'title' => $post->post_title,
      'content' => $post->post_content,
      'date' => $post->post_date,
      'featured_image' => get_the_post_thumbnail_url($post->ID, 'full'),
      'custom_fields' => get_fields($post->ID),
    ];
  }

  return $data;
}
```

## 4. WordPress Security Configuration

### 4.1 Configure Wordfence Security

1. Go to Wordfence > All Options
2. Configure Firewall options:
   - Enable Rate Limiting
   - Block IPs that exceed thresholds
3. Configure Login Security:
   - Enable brute force protection
   - Limit login attempts
4. Configure Scanning:
   - Enable automatic scanning
   - Configure scan schedule
5. Save settings

### 4.2 Configure WP Super Cache

1. Go to Settings > WP Super Cache
2. Enable caching
3. Configure cache settings:
   - Select "Use mod_rewrite to serve cache files"
   - Enable "Compress pages"
   - Enable "Cache hits to this website for quick access"
4. Under "Advanced":
   - Enable "Don't cache pages for known users"
   - Enable "Don't cache pages with GET parameters"
5. Save settings and update .htaccess when prompted

## 5. Testing the Configuration

### 5.1 Test JWT Authentication

1. Use Postman to test authentication endpoints:
   - Login: `POST https://your-site.com/wp-json/jwt-auth/v1/token`
   - Validate: `POST https://your-site.com/wp-json/jwt-auth/v1/token/validate`

### 5.2 Test REST API Endpoints

1. Test retrieving posts:
   - `GET https://your-site.com/wp-json/wp/v2/posts`
2. Test retrieving custom post types:
   - `GET https://your-site.com/wp-json/wp/v2/app_content`
3. Test custom endpoints (if created):
   - `GET https://your-site.com/wp-json/app/v1/content`

### 5.3 Test Email Functionality

1. Use the WP Mail SMTP test email feature
2. Test password reset functionality in WordPress

## 6. Troubleshooting

### 6.1 JWT Authentication Issues

- **Problem**: 403 Forbidden errors
  - **Solution**: Check CORS configuration in .htaccess

- **Problem**: "Signature verification failed"
  - **Solution**: Verify JWT_AUTH_SECRET_KEY in wp-config.php

### 6.2 Email Configuration Issues

- **Problem**: Test emails not sending
  - **Solution**: Verify SMTP credentials and server settings

- **Problem**: Authentication errors
  - **Solution**: Check username/password and try using app passwords

### 6.3 REST API Issues

- **Problem**: Custom fields not appearing in API response
  - **Solution**: Ensure "Show in REST API" is enabled for each field

- **Problem**: Cannot access custom post types via API
  - **Solution**: Verify "show_in_rest" is set to true for the post type

---

This guide covers the essential configuration steps for WordPress plugins and DirectAdmin email settings. For more advanced configurations or troubleshooting, refer to the official documentation for each plugin or contact your hosting provider.
