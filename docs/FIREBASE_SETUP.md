# Firebase Setup Guide for WellSense

## Creating a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project"
3. Enter a project name (e.g., "WellSense")
4. Configure Google Analytics (optional)
5. Click "Create project"

## Setting Up Realtime Database

1. In the Firebase console, navigate to "Build > Realtime Database"
2. Click on "Create Database"
3. Choose a location (preferably closest to your users)
4. Start in "test mode" for development (change to production rules later)
5. Click "Enable"

## Database Structure

Ensure your database follows this structure:

```
/sensor
  /livedata
    - heartRate: float
    - temperature: float
    - timestamp: long
  /status
    - status: string
    - timestamp: long
```

## Security Rules

1. In the Realtime Database section, go to the "Rules" tab
2. Replace the default rules with those provided in the `Firebase/database_rules/rules.json` file
3. Click "Publish"

## Setting Up Authentication

1. Navigate to "Build > Authentication"
2. Click on "Get started"
3. Enable "Email/Password" authentication
4. Set up your first user account

## Integrating with Mobile App

1. In the Firebase console, click on the gear icon and select "Project settings"
2. In the "Your apps" section, click on the platform you're developing for (Android/iOS)
3. Follow the setup instructions to register your app:
   - For Android: Download the `google-services.json` and place it in `Mobile_App/android/app/`
   - For iOS: Download the `GoogleService-Info.plist` and place it in `Mobile_App/ios/Runner/`

## Integrating with ESP32

1. In the Firebase console, go to "Project settings > Service accounts"
2. Generate a new private key for Admin SDK
3. Use the provided configuration details in your ESP32 code:
   - API Key
   - Database URL
   - Project ID 