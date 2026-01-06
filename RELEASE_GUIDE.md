# Where Is Kenny - Google Play Release Guide

**Package Name:** `com.eried.whereiskenny`
**Version:** 1.0.0 (Build 1)

## Step 1: Create a Keystore for Signing

Run this command to create a keystore (you'll need this to sign your app):

```bash
keytool -genkey -v -keystore ~/whereiskenny-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias whereiskenny
```

**Important:** Save the keystore file and remember the passwords!

## Step 2: Configure Signing in Flutter

Create a file `android/key.properties` with this content:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=whereiskenny
storeFile=C:/Users/YOUR_USERNAME/whereiskenny-release-key.jks
```

Replace:
- `YOUR_KEYSTORE_PASSWORD` - password you chose in Step 1
- `YOUR_KEY_PASSWORD` - key password you chose in Step 1
- `YOUR_USERNAME` - your Windows username

## Step 3: Update build.gradle.kts for Release Signing

Add this to `android/app/build.gradle.kts` before the `android {` block:

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Then update the `buildTypes` section:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties['keyAlias']
        keyPassword = keystoreProperties['keyPassword']
        storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword = keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## Step 4: Build the Release Bundle

```bash
flutter build appbundle --release
```

The output will be at: `build/app/outputs/bundle/release/app-release.aab`

## Step 5: Google Play Console Setup

### 5.1 Create App in Play Console

1. Go to: https://play.google.com/console
2. Click "Create app"
3. Fill in:
   - **App name:** Where Is Kenny
   - **Default language:** English (United States)
   - **App or game:** App
   - **Free or paid:** Free
4. Accept policies and create

### 5.2 Set Up App Content

Complete all required sections:
- **App access:** All functionality available
- **Ads:** No ads
- **Content rating:** Complete questionnaire (likely PEGI 3+)
- **Target audience:** Choose appropriate age groups
- **Privacy policy:** You'll need a URL or mark as not required
- **Data safety:** Complete the form about data collection

### 5.3 Create Internal Testing Release

1. Go to "Testing" → "Internal testing"
2. Click "Create new release"
3. Upload the AAB file from Step 4
4. Add release notes (e.g., "Initial release")
5. Review and roll out

### 5.4 Add Internal Testers

1. In "Internal testing", click "Testers" tab
2. Create an email list with tester emails
3. Copy the **testing link** that appears

## Step 6: Get Your Testing Link

After creating the internal testing release, you'll get a link like:

```
https://play.google.com/apps/internaltest/XXXXXXXXXX
```

Share this link with your testers. They'll need:
1. A Gmail account
2. To be added to your tester list
3. To opt-in via the link
4. To download from Play Store

## Alternative: Direct APK Install (Faster Testing)

Build an APK instead:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Send this file directly to testers for installation (they'll need to enable "Install from unknown sources").

## Current Configuration

✅ Package name: `com.eried.whereiskenny`
✅ Version: 1.0.0 (Build 1)
✅ App name: "Where Is Kenny"
✅ Icons: Generated with sharp edges
✅ Splash screen: Configured
✅ Permissions: Location access

## Notes

- **Keystore backup:** Keep `whereiskenny-release-key.jks` safe - you need it for ALL future updates
- **Git ignore:** Add `android/key.properties` to `.gitignore` (never commit passwords)
- **Internal testing:** Up to 100 testers, updates available in minutes
- **Open testing:** Unlimited testers, updates take hours to review
- **Production:** Full review process, can take days

## Troubleshooting

### "Signing config not found"
- Make sure `android/key.properties` exists
- Check file paths in `key.properties`

### "Upload failed - duplicate package"
- Increment `versionCode` in `build.gradle.kts`

### "Missing required sections"
- Complete all sections in Play Console before releasing
