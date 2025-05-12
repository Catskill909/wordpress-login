# Preventing Email Verification Codes from Going to Spam

This document analyzes why emails sent from our Flutter app through our WordPress plugin are being flagged as spam, despite having proper DMARC configuration for the djchucks.com domain.

## Current Setup Analysis

### Email Infrastructure
- **Domain**: djchucks.com
- **DMARC**: Properly configured and verified
- **Email Sender**: WP Mail SMTP plugin with login@djchucks.com
- **WordPress Plugin**: Custom WP Flutter Auth plugin for verification codes

### Test Results
- **Direct Script Tests**: Emails sent via curl/script tests do NOT go to spam
- **App-Generated Emails**: Emails triggered by the Flutter app DO go to spam
- **Same Endpoints**: Both methods use identical API endpoints

## App Implementation Review

### Flutter App Email Request

```dart
// In auth_remote_data_source.dart
Future<void> forgotPassword(String email) async {
  try {
    LoggerUtil.i('Requesting password reset code for email: $email');

    final response = await _dioClient.post(
      AppConstants.requestResetCodeEndpoint,
      data: {
        'email': email,
      },
    );

    LoggerUtil.i('Password reset code request response: $response');

    if (response['status'] != 'success') {
      throw ApiException(
          message: response['message'] ?? 'Failed to send verification code');
    }

    return;
  } catch (e) {
    LoggerUtil.e('Request reset code error: ${e.toString()}', e);

    if (e is ApiException) {
      rethrow;
    }

    throw ApiException(
        message: 'Failed to request reset code: ${e.toString()}');
  }
}
```

### Working Script Implementation

```bash
#!/bin/bash
# Direct test script that works (emails don't go to spam)

curl -v -X POST \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\"}" \
  "https://djchucks.com/tester/wp-json/wp-flutter/v1/request-reset-code"
```

## WordPress Plugin Analysis: WordPress Flutter Custom Password Reset

Our custom WordPress plugin handles email sending through the following process:

1. Receives request at `/wp-json/wp-flutter/v1/request-reset-code` endpoint
2. Generates verification code and stores it in the database
3. Uses `wp_mail()` function to send the email via WP Mail SMTP
4. Returns success/failure response to the client

### Plugin Structure and Email Handling

The WordPress Flutter Custom Password Reset plugin likely follows this structure:

```php
// Main plugin file structure
function wp_flutter_send_reset_code($request) {
    $email = $request->get_param('email');

    // Generate random code
    $code = wp_generate_password(6, false, false);

    // Store code in user meta or temporary database
    store_verification_code($email, $code);

    // Send email
    $subject = 'Your Password Reset Code';
    $message = 'Your verification code is: ' . $code;

    $headers = array(
        'Content-Type: text/html; charset=UTF-8',
        'From: DJ Chucks <login@djchucks.com>'
    );

    $mail_sent = wp_mail($email, $subject, $message, $headers);

    if ($mail_sent) {
        return array(
            'status' => 'success',
            'message' => 'Verification code sent'
        );
    } else {
        return array(
            'status' => 'error',
            'message' => 'Failed to send verification code'
        );
    }
}

// Register REST API endpoint
add_action('rest_api_init', function() {
    register_rest_route('wp-flutter/v1', '/request-reset-code', array(
        'methods' => 'POST',
        'callback' => 'wp_flutter_send_reset_code',
        'permission_callback' => '__return_true'
    ));
});
```

## Key Differences Analysis

### 1. Request Headers

**Script (Working):**
- Explicitly sets `Content-Type: application/json`
- Uses verbose mode (`-v`) which includes additional headers
- May include different User-Agent information

**App (Going to Spam):**
- Uses Dio client's default headers
- May include Flutter/Dart specific User-Agent
- Possibly missing headers that email providers use for filtering

### 2. Request Format

**Script (Working):**
- Raw JSON string in the exact format expected by the server
- Direct HTTP request without middleware

**App (Going to Spam):**
- Uses Dio's JSON serialization
- Passes through multiple layers (Dio, interceptors, etc.)
- May have subtle differences in the final request format

### 3. Email Generation Differences

When the WordPress plugin receives requests from different sources, it might:
- Apply different templates
- Use different priority settings
- Include different metadata in the email headers

## WordPress Plugin Email Generation

The WordPress plugin likely uses code similar to:

```php
function send_verification_email($email, $code) {
    $subject = 'Your Verification Code';
    $message = 'Your verification code is: ' . $code;

    $headers = array(
        'Content-Type: text/html; charset=UTF-8',
        'From: DJ Chucks <login@djchucks.com>'
    );

    return wp_mail($email, $subject, $message, $headers);
}
```

## Potential Issues and Solutions

### 1. Request Headers Mismatch

**Issue**: The app may not be sending the same headers as the working script.

**Solution**: Modify the app's `forgotPassword` method in `auth_remote_data_source.dart` to match the exact headers from the working script:

```dart
@override
Future<void> forgotPassword(String email) async {
  try {
    LoggerUtil.i('Requesting password reset code for email: $email');

    // Create a custom Dio instance to match the curl request exactly
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // Set headers to match the curl request
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter/1.0', // Simplified user agent
    };

    // Log the exact request being made
    LoggerUtil.i('Making request to: ${AppConstants.requestResetCodeEndpoint}');
    LoggerUtil.i('With headers: ${dio.options.headers}');
    LoggerUtil.i('With data: {"email": "$email", "source": "mobile_app"}');

    // Make the request with the exact same format as the curl command
    final response = await dio.post(
      AppConstants.requestResetCodeEndpoint,
      data: {
        'email': email,
        'source': 'mobile_app', // Add source identifier
      },
    );

    LoggerUtil.i('Password reset code request response: ${response.data}');

    if (response.data['status'] != 'success') {
      throw ApiException(
          message: response.data['message'] ?? 'Failed to send verification code');
    }

    return;
  } catch (e) {
    LoggerUtil.e('Request reset code error: ${e.toString()}', e);

    if (e is ApiException) {
      rethrow;
    }

    throw ApiException(
        message: 'Failed to request reset code: ${e.toString()}');
  }
}
```

### 2. Email Template Differences

**Issue**: The WordPress plugin might use different email templates based on request source.

**Solution**: Add a source identifier to the app's request:

```dart
data: {
  'email': email,
  'source': 'mobile_app', // Identify the source as the mobile app
},
```

### 3. WordPress Plugin Email Headers

**Issue**: The WordPress Flutter Custom Password Reset plugin might not be adding proper email headers for app-originated requests.

**Solution**: Modify the WordPress plugin to add spam-prevention headers for all emails:

```php
// Enhanced email sending function for the WordPress Flutter Custom Password Reset plugin
function wp_flutter_send_reset_code($request) {
    $email = $request->get_param('email');
    $source = $request->get_param('source'); // Optional source parameter

    // Generate random code
    $code = wp_generate_password(6, false, false);

    // Store code in user meta or temporary database
    store_verification_code($email, $code);

    // Create better email content
    $subject = 'Your DJ Chucks Verification Code';

    // HTML message with better formatting
    $message = '
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Your Verification Code</h2>
        <p>You requested a verification code for your DJ Chucks account.</p>
        <div style="background-color: #f5f5f5; padding: 15px; text-align: center; font-size: 24px; letter-spacing: 5px; margin: 20px 0;">
            <strong>' . $code . '</strong>
        </div>
        <p>This code will expire in 15 minutes.</p>
        <p>If you did not request this code, please ignore this email.</p>
        <hr>
        <p style="font-size: 12px; color: #777;">DJ Chucks, Inc. • 123 Main St • New York, NY 10001</p>
    </div>';

    // Add comprehensive headers to prevent spam filtering
    $headers = array(
        'Content-Type: text/html; charset=UTF-8',
        'From: DJ Chucks <login@djchucks.com>',
        'Reply-To: support@djchucks.com',
        'X-Priority: 1',
        'X-MSMail-Priority: High',
        'Importance: High',
        'X-Mailer: WordPress/' . get_bloginfo('version'),
        'X-Source: WordPress Flutter App'
    );

    // If request is from mobile app, add additional headers
    if ($source == 'mobile_app') {
        $headers[] = 'X-Mobile-App: true';
    }

    // Log the email attempt (for debugging)
    error_log('Sending verification email to: ' . $email . ' from source: ' . $source);

    // Send the email
    $mail_sent = wp_mail($email, $subject, $message, $headers);

    // Log the result
    error_log('Email send result: ' . ($mail_sent ? 'success' : 'failure'));

    if ($mail_sent) {
        return array(
            'status' => 'success',
            'message' => 'Verification code sent'
        );
    } else {
        return array(
            'status' => 'error',
            'message' => 'Failed to send verification code'
        );
    }
}
```

### 4. DKIM Alignment

**Issue**: While DMARC is configured, DKIM alignment might be incorrect for emails sent from WordPress.

**Solution**: Ensure the WordPress SMTP configuration is using the same DKIM keys as configured in DMARC.

## Next Steps for Investigation

1. **Compare Full HTTP Requests**: Capture and compare the complete HTTP requests from both the app and the script
2. **Examine Email Headers**: Look at the full email headers from both sources to identify differences
3. **Test with Header Matching**: Modify the app to exactly match the script's headers
4. **WordPress Plugin Logging**: Add detailed logging in the WordPress plugin to see how it processes different requests
5. **Email Provider Analysis**: Use email deliverability testing tools to analyze why specific emails are marked as spam

## Implementation Plan

### 1. Flutter App Changes

1. **Update the `forgotPassword` Method**:
   - Modify `auth_remote_data_source.dart` with the code provided above
   - Use a custom Dio instance with headers matching the working script
   - Add the 'source' parameter to identify requests from the mobile app

2. **Add Detailed Logging**:
   - Implement comprehensive logging of request details and responses
   - Log the exact headers and payload being sent

### 2. WordPress Plugin Changes

1. **Enhance Email Headers**:
   - Update the WordPress Flutter Custom Password Reset plugin with the improved email function
   - Add all recommended email headers (X-Priority, Importance, etc.)
   - Implement better HTML formatting for the email content

2. **Add Source Detection**:
   - Modify the plugin to detect and handle requests from different sources
   - Add special handling for mobile app requests

3. **Implement Error Logging**:
   - Add detailed error logging in the WordPress plugin
   - Log all email sending attempts and results

### 3. Testing and Verification

1. **Test with Multiple Email Providers**:
   - Test with Gmail, Yahoo, Outlook, and other major providers
   - Document which providers mark emails as spam and which don't

2. **Use Email Deliverability Tools**:
   - Test emails with tools like mail-tester.com
   - Analyze the spam score and specific issues

3. **Compare Script vs. App Requests**:
   - Use network monitoring tools to capture and compare the exact requests
   - Ensure the app's requests match the working script exactly

### 4. Monitoring and Iteration

1. **Implement Delivery Tracking**:
   - Add a tracking pixel or link in emails to monitor open rates
   - Track which emails are delivered successfully

2. **Gradual Improvements**:
   - Make one change at a time and test the results
   - Document which changes have the most impact

By systematically implementing these changes and carefully testing each modification, we can identify and fix the specific factors causing app-generated emails to be marked as spam.

## Conclusion

The key insight from our analysis is that while the djchucks.com domain has proper DMARC configuration, there are subtle differences between how the test scripts and the Flutter app make requests to the WordPress plugin. These differences likely affect how the emails are generated and how email providers evaluate them for spam.

The most promising approach is to:

1. Make the Flutter app's requests match the working script exactly
2. Enhance the WordPress plugin's email headers and formatting
3. Test systematically with different email providers

By focusing on these specific areas, we can resolve the spam issue while maintaining the existing functionality of both the Flutter app and the WordPress plugin. The goal is to make minimal, targeted changes that address the specific factors causing emails to be flagged as spam.
