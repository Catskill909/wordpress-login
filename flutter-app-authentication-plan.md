Plan for Flutter App Authentication with WordPress and DirectAdmin Email:

I. Core Authentication Features to Implement:
* User Registration: Allowing new users to create accounts.
* Email Verification: Confirming the user's email address during registration.
* Login: Enabling existing users to sign in with their email and password.
* Logout: Allowing users to securely sign out of the app.
* Lost Password Recovery: Enabling users to reset their forgotten passwords via email.
* Remember Me (Optional but Recommended): Persisting user sessions across app restarts.
* Profile Management (Basic): Allowing users to view and potentially update basic profile information (e.g., username, email).
II. WordPress Backend Setup:
1. Essential WordPress Plugins:
    * WP REST API (Core): Ensure this is enabled (usually default). This is the foundation for communication with your Flutter app.
    * WP JSON API User Authentication: This plugin provides dedicated endpoints for user registration, login, password reset, and user data retrieval, simplifying development.
    * Custom Post Type UI (CPT UI) & Advanced Custom Fields (ACF) (Optional but Recommended): While not strictly for authentication, these can be useful for storing additional user-related data beyond the default WordPress fields.
    * WP Mail SMTP: This is crucial for reliable email sending via your DirectAdmin email servers.
2. WordPress Configuration:
    * Install and Configure WP Mail SMTP:
        * Install the plugin.
        * Navigate to WP Mail SMTP > Settings.
        * Choose "Other SMTP".
        * Enter the SMTP host, port, encryption type (usually TLS or SSL), username (your full email address managed in DirectAdmin), and password for your email account.
        * Test the email sending to ensure it's working correctly.
    * Install and Activate WP JSON API User Authentication: No complex configuration is usually needed. The endpoints will become available upon activation.
    * (Optional) Install and Configure CPT UI & ACF: If you plan to store extra user data.
3. WordPress API Endpoints: The WP JSON API User Authentication plugin will provide the following key endpoints:
    * /wp-json/wp/v2/users/register: For user registration.
    * /wp-json/jwt-auth/v1/token: For user login (if you choose JWT, see section IV).
    * /wp-json/wp-json-api/v1/users/lost_password: To initiate the password reset process.
    * /wp-json/wp-json-api/v1/users/reset_password: To complete the password reset with the token.
    * /wp-json/wp/v2/users/me: To get the currently logged-in user's data (requires authentication).
III. Flutter App Development:
1. Essential Flutter Packages:
    * http or dio: For making HTTP requests to your WordPress API endpoints. dio offers more features like request cancellation and interceptors.
    * shared_preferences or flutter_secure_storage: For securely storing authentication tokens or session information on the device. flutter_secure_storage is recommended for sensitive data.
    * provider, bloc, or riverpod: For managing the authentication state within your Flutter app. These provide structured ways to handle login status, user data, and trigger UI updates.
    * form_builder_validators: For validating user input in registration and login forms.
    * email_validator: For specifically validating email format.
2. Flutter Authentication Flow Implementation:
    * Registration Screen:
        * UI with fields for username, email, and password.
        * Input validation using form_builder_validators and email_validator.
        * On submission, make a POST request to the /wp-json/wp/v2/users/register endpoint with the user data.
        * Handle success (show a message about email verification) and error responses from the API.
    * Email Verification:
        * WordPress Backend: When a user registers successfully via the API, WordPress (with WP JSON API User Authentication) will automatically send a verification email to the registered address using wp_mail() (which will now use your DirectAdmin SMTP). This email will contain a link with a unique activation key.
        * Flutter App: You can implement one of two approaches:
            * Web-based Verification: The link in the email directs the user to a page on your WordPress site. This page will handle the verification logic (using the activation key in the URL and interacting with WordPress functions) and then potentially redirect the user back to your app (using a deep link).
            * In-App Verification (More Complex): You could potentially create a custom API endpoint in WordPress that accepts the activation key directly from your Flutter app. The email would contain the key, and the user would enter it in a verification screen in your app. This requires more custom development on the WordPress side. The web-based approach is generally simpler and more common.
    * Login Screen:
        * UI with fields for email and password.
        * Input validation.
        * On submission, make a POST request to the /wp-json/jwt-auth/v1/token endpoint (if using JWT - see section IV) or the /wp-json/wp-json-api/v1/users/login endpoint with the user credentials.
        * Handle successful login (store the received token or session data) and display error messages for incorrect credentials.
    * Logout:
        * Clear any stored authentication tokens or session data from shared_preferences or flutter_secure_storage.
        * Update the app's state to reflect the user being logged out.
    * Lost Password Screen:
        * UI with a field for the user's email address.
        * Input validation.
        * On submission, make a POST request to the /wp-json/wp-json-api/v1/users/lost_password endpoint with the email address.
        * Display a message indicating that a password reset link has been sent to their email.
    * Password Reset Screen:
        * WordPress Backend: The /wp-json/wp-json-api/v1/users/lost_password endpoint will generate a reset key and send an email with a link to a WordPress page containing the reset key in the URL. This page will have a form for the user to enter a new password. Upon submission, this page will call the /wp-json/wp-json-api/v1/users/reset_password endpoint with the reset key, user login (usually email), and the new password.
        * Flutter App: You would typically direct the user to the WordPress password reset page via the link in the email. After successfully resetting their password on the web page, they can then log in to your Flutter app with their new credentials. Handling the entire reset process within the Flutter app is more complex and less common.
    * Remember Me (Optional):
        * Upon successful login, store a flag or the authentication token (if using JWT) in shared_preferences or flutter_secure_storage.
        * On app startup, check if this data exists and attempt to automatically log the user in (e.g., by verifying the token with WordPress if using JWT).
    * Profile Management:
        * If needed, use the /wp-json/wp/v2/users/me endpoint (with proper authentication headers) to fetch the logged-in user's data.
        * Implement UI to display this information.
        * If you want users to update data, you'll need to use the /wp-json/wp/v2/users/<id> endpoint with a PUT request (again, with proper authentication and ensuring appropriate permissions).
IV. Security Considerations:
* HTTPS: Ensure your WordPress site and API are served over HTTPS to encrypt all communication.
* Input Validation: Always validate user input on both the Flutter app and the WordPress backend to prevent common security vulnerabilities.
* Password Hashing: WordPress handles password hashing securely by default. Ensure you are using the built-in WordPress user management functions.
* Rate Limiting: Implement rate limiting on your API endpoints (especially login and registration) to prevent brute-force attacks. Plugins like "Limit Login Attempts Reloaded" can help with this on the WordPress side.
* Token Security (if using JWT):
    * Use a strong secret key for JWT signing on the WordPress side.
    * Store tokens securely in your Flutter app using flutter_secure_storage.
    * Implement proper token expiration and refresh mechanisms if needed.
* Email Security (DirectAdmin): Ensure your DirectAdmin email server is configured with SPF, DKIM, and DMARC records to improve email deliverability and prevent spoofing.
V. Email Management with DirectAdmin:
* You will manage the actual email accounts (creation, deletion, password changes, etc.) within your DirectAdmin control panel.
* The WP Mail SMTP plugin will act as a bridge, using the credentials of an email account you manage in DirectAdmin to send emails from your WordPress site.
* Ensure the email account you configure in WP Mail SMTP has sufficient sending limits and is properly configured in DirectAdmin.
VI. Recommended Approach (Focus on Simplicity and Security):
1. Use WP JSON API User Authentication: It simplifies the core authentication endpoints significantly.
2. Implement Email Verification with Web-Based Confirmation: The link in the email directs the user to a WordPress page for verification.
3. Handle Password Reset Primarily Through the WordPress Web Interface: Utilize the endpoints provided by WP JSON API User Authentication and direct users to the WordPress reset page via the email link.
4. Use flutter_secure_storage: For securely storing any authentication tokens or session identifiers in your Flutter app.
5. Employ a State Management Solution (provider, bloc, or riverpod): To manage the user's authentication state within your Flutter app effectively.
6. Prioritize HTTPS and input validation.
7. Use WP Mail SMTP with your DirectAdmin email server details for reliable email sending.

PROMPT

## AI Prompt: Flutter App Authentication with WordPress

**Goal:** Implement a full-featured authentication system for a Flutter mobile application using WordPress as the backend and leveraging a DirectAdmin-managed email server for email functionalities (registration confirmation, lost password).

**Context:** The Flutter app needs standard authentication features: registration, email verification, login, logout, lost password recovery, and potentially "remember me" functionality. WordPress will handle user data and email sending via WP Mail SMTP configured with DirectAdmin email server details.

**WordPress Plugins in Use:**
* WP REST API (Core - Enabled)
* WP JSON API User Authentication
* WP Mail SMTP (Configured with DirectAdmin Email)
* (Optional) Custom Post Type UI & Advanced Custom Fields (if needed for extra user data)

**Flutter Packages in Use:**
* http or dio (for API requests)
* shared_preferences or flutter_secure_storage (for local storage of auth data)
* provider, bloc, or riverpod (for state management)
* form_builder_validators (for form validation)
* email_validator (for email validation)

**Specific Tasks/Questions for the AI:**

**(Please specify the exact task or question you have for the AI. Be as detailed as possible.)**

**Examples:**

* "Generate the Flutter code for the user registration screen, including input fields for username, email, and password, and basic validation using `form_builder_validators` and `email_validator`. Include a function to send the registration data to the `/wp-json/wp/v2/users/register` endpoint."
* "Provide the WordPress PHP code for a custom function that handles email verification when a user clicks the link in their confirmation email. This function should receive an activation key from the URL, verify it against the database, and mark the user's email as confirmed."
* "Show me how to implement user login in Flutter using the `/wp-json/jwt-auth/v1/token` endpoint (assuming JWT is enabled). Include code for sending credentials and storing the received token securely using `flutter_secure_storage`."
* "What are the best practices for securely storing JWT tokens in a Flutter application?"
* "Generate the Flutter code for the 'Lost Password' screen that sends an email address to the `/wp-json/wp-json-api/v1/users/lost_password` endpoint."
* "Explain the process of handling the password reset flow using the `/wp-json/wp-json-api/v1/users/reset_password` endpoint in WordPress and how the Flutter app would direct the user to the WordPress reset page."

**Output Requirements:**

* Specify the desired output format (e.g., Flutter code snippet, WordPress PHP code, explanation, list of steps).
* Request comments and explanations for the generated code or steps.

**Remember to be specific and break down your tasks into smaller, manageable questions for the AI.**
