# Firebase Setup Instructions

## Prerequisites
You need to create a Firebase project and add your Android app to it.

## Steps to Setup Firebase

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard

### 2. Add Android App to Firebase Project
1. In the Firebase Console, click on the Android icon to add an Android app
2. Enter the package name: `com.example.jarz_pos`
3. (Optional) Enter app nickname: "Jarz POS"
4. (Optional) Add SHA-1 certificate fingerprint for development
5. Click "Register app"

### 3. Download google-services.json
1. After registering the app, Firebase will prompt you to download `google-services.json`
2. Download this file
3. Place it in: `android/app/google-services.json`
   - **Important**: This file should be in the same directory as `build.gradle.kts`

### 4. Get Firebase Service Account Key (for FCM V1 API)
The modern way to send push notifications is using the Firebase Admin SDK with a service account key instead of the legacy server key.

1. In Firebase Console, click on the **gear icon** (⚙️) next to "Project Overview" at the top left
2. Select **"Project settings"**
3. Go to the **"Service accounts"** tab
4. Click **"Generate new private key"**
5. Confirm by clicking **"Generate key"**
6. A JSON file will be downloaded - this is your service account key
7. **Keep this file secure!** It contains sensitive credentials

**Important:** The service account JSON file should never be committed to git. Store it securely on your server.

### 5. Install Firebase Admin SDK on Backend
The backend needs the Firebase Admin SDK Python package to send push notifications.

```bash
# In your frappe-bench directory
bench pip install firebase-admin

# Or if you have a requirements.txt in your app
bench setup requirements
```

### 6. Configure Backend with Firebase Service Account
Add the Firebase service account credentials to your ERPNext site configuration:

**Option 1: Using file path (Recommended for production)**
```bash
# Place the service account JSON file on your server
# For example: /home/frappe/frappe-bench/sites/firebase-service-account.json

# In your frappe-bench directory
bench --site YOUR_SITE_NAME set-config fcm_service_account_path "/path/to/firebase-service-account.json"
```

**Option 2: Using inline JSON (for development/testing)**
```bash
# In your frappe-bench directory
bench --site YOUR_SITE_NAME set-config fcm_service_account '{"type":"service_account","project_id":"your-project",...}'
```

Or add it manually to `sites/YOUR_SITE_NAME/site_config.json`:
```json
{
  "fcm_service_account_path": "/path/to/firebase-service-account.json"
}
```

**Note:** After configuring, restart your bench:
```bash
bench restart
```

### 7. Verify Setup
After placing the `google-services.json` file, try building again:
```bash
flutter run -d 192.168.1.14:5555 --dart-define=ENV=staging
```

## Template File
A template file `google-services.json.template` has been created for reference.
**Do not commit the actual google-services.json file** - it contains sensitive API keys.

## Troubleshooting

### Build fails with "google-services.json is missing"
- Ensure the file is in `android/app/google-services.json` (not in a subdirectory)
- Verify the file is valid JSON
- Check that the package name in the file matches `com.example.jarz_pos`

### FCM messages not received
- Verify FCM is enabled in Firebase Console
- Check that the Server Key is correctly configured in the backend
- Ensure the app has notification permissions
- Check device logs for FCM token registration

## Security Notes
- `google-services.json` is added to `.gitignore` to prevent committing sensitive keys
- Each developer/deployment environment should have their own Firebase project or use Firebase App Distribution
- For production, create a separate Firebase project with proper security rules
