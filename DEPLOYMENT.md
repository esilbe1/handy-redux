# Deployment Guide

This guide covers everything from first-time local setup to App Store distribution.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Clone & Generate Project](#2-clone--generate-project)
3. [Code Signing](#3-code-signing)
4. [App Group Registration](#4-app-group-registration)
5. [Build & Run on Device](#5-build--run-on-device)
6. [First-Run Setup on iPhone](#6-first-run-setup-on-iphone)
7. [TestFlight Distribution](#7-testflight-distribution)
8. [App Store Submission](#8-app-store-submission)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

### Mac

| Requirement | Version | Notes |
|---|---|---|
| macOS | Sequoia 15.0+ | Required by Xcode 16 |
| Xcode | 16.0+ | [Download from Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| Xcode Command Line Tools | Latest | `xcode-select --install` |
| XcodeGen | Any | `brew install xcodegen` |
| Homebrew | Any | [brew.sh](https://brew.sh) |

### Apple Developer Account

| Use case | Account type | Cost |
|---|---|---|
| Personal testing on your own iPhone | Free Apple ID | Free |
| TestFlight beta distribution | Apple Developer Program | $99/yr |
| App Store release | Apple Developer Program | $99/yr |

> A **free Apple ID** is sufficient to build and run the app on your personal device for up to 7 days before re-signing is required. Keyboard extensions work with a free account.

### iPhone

- **iOS 18.0 or later** (required — the app uses `Translation` and `ActivityKit` frameworks)
- Any iPhone with an A-series chip (iPhone 6s or newer can run iOS 18)
- For WhisperKit models: iPhone XS / A12 or newer recommended for reasonable speed

---

## 2. Clone & Generate Project

```bash
# 1. Clone the repository
git clone https://github.com/esilbe1/handy-redux.git
cd handy-redux

# 2. Check out the development branch
git checkout claude/voice-transcription-app-jpdYc

# 3. Install XcodeGen if you don't have it
brew install xcodegen

# 4. Generate Handy.xcodeproj from project.yml
xcodegen generate

# 5. Open in Xcode
open Handy.xcodeproj
```

> Every time you modify `project.yml` (adding targets, changing settings, etc.), re-run `xcodegen generate`. The generated `Handy.xcodeproj` is intentionally **not** committed to git — `project.yml` is the source of truth.

---

## 3. Code Signing

### Automatic signing (recommended for development)

1. In Xcode, select the **Handy** project in the Navigator (top-level item)
2. For **each of the four targets** (`Handy`, `HandyKeyboard`, `HandyWidget`, `HandyShare`):
   - Click the target name
   - Go to **Signing & Capabilities** tab
   - Check **Automatically manage signing**
   - Under **Team**, select your Apple ID or Developer Program account
3. Xcode will create provisioning profiles and register bundle IDs automatically

The four bundle IDs that will be registered:

| Target | Bundle ID |
|---|---|
| Handy (main app) | `com.handy.handy-app` |
| HandyKeyboard | `com.handy.handy-app.keyboard` |
| HandyWidget | `com.handy.handy-app.widget` |
| HandyShare | `com.handy.handy-app.share` |

> If you want different bundle IDs (e.g. using your own reverse domain), edit them in `project.yml` under each target's `PRODUCT_BUNDLE_IDENTIFIER` before running `xcodegen generate`. Also update `HandyConstants.keyboardBundleId` in `Shared/Constants.swift` to match the keyboard bundle ID.

### Free Apple ID limitations

- App expires on device after **7 days** — you must rebuild and reinstall
- Maximum **3 apps** signed with a free account at a time
- No TestFlight or App Store distribution
- All features work for personal testing

---

## 4. App Group Registration

The app and keyboard extension share data via App Group `group.com.handy.shared`. With **Automatic signing**, Xcode registers this for you. With manual signing, you must register it yourself.

### Automatic (Xcode handles it)

When you first build, Xcode adds the App Group to both the main app and keyboard extension entitlements and registers it with Apple. No action needed.

### Manual (if using manual provisioning profiles)

1. Log in to [developer.apple.com](https://developer.apple.com)
2. Go to **Certificates, Identifiers & Profiles → Identifiers**
3. Click **+** → **App Groups** → Continue
4. Description: `Handy Shared`
5. Identifier: `group.com.handy.shared`
6. Register
7. Go to each of your four **App IDs** and add the `group.com.handy.shared` App Group capability
8. Regenerate provisioning profiles for all four targets

---

## 5. Build & Run on Device

### Connect your iPhone

1. Connect iPhone to Mac via USB (or use wireless pairing in Xcode 14+)
2. On iPhone: tap **Trust** when prompted
3. In Xcode toolbar: select your iPhone as the destination (dropdown next to the scheme name)

### First build — resolve Swift Package dependencies

Xcode will automatically fetch:
- `WhisperKit` (~10 MB package, models downloaded at runtime)
- `FluidAudio` (~5 MB package)

This happens on first open and takes 1–2 minutes.

### Build & Run

1. Select the **Handy** scheme in the toolbar
2. Press **Cmd+R** (or Product → Run)
3. The app installs and launches on your iPhone

> **Keyboard extensions cannot be run directly.** The `HandyKeyboard` scheme in Xcode is for build validation only. The keyboard runs inside the host app (Notes, Mail, etc.) after you enable it in Settings.

### Expected build time

| Situation | Time |
|---|---|
| First build (cold) | 3–8 minutes |
| Incremental build | 10–30 seconds |

---

## 6. First-Run Setup on iPhone

### Step 1: Download a transcription model

The app ships without models (they're too large to bundle). On first launch:

1. Open the **Handy** app
2. Tap **Settings** → **Models**
3. Tap **Download** next to your preferred model:

| Model | Size | Speed | Quality | Best for |
|---|---|---|---|---|
| Apple Speech | Built-in | Fastest | Good | Everyday use, older devices |
| Whisper Tiny | ~75 MB | Fast | OK | Older devices |
| **Whisper Base (recommended)** | ~150 MB | Good | Better | iPhone XS+ |
| Whisper Small | ~500 MB | Slower | Best | iPhone 15+ |

4. Wait for the download to complete (~30 seconds on Wi-Fi for Base)
5. Tap **Load** to activate the model

### Step 2: Enable the Handy keyboard

1. Open **Settings** app
2. Navigate to **General → Keyboard → Keyboards**
3. Tap **Add New Keyboard…**
4. Scroll to find **Handy** and tap it
5. Tap **Handy** in the list
6. Toggle **Allow Full Access** → tap **Allow**

> Full Access is required for the keyboard to communicate with the main app (via App Group) to perform voice recording. Without it, the mic button will show an error.

### Step 3: Test voice input

1. Open **Notes** (or any app with a text field)
2. Tap a text field to bring up the keyboard
3. Tap the **globe** key to switch keyboards → select **Handy**
4. Tap the **waveform** mic button
5. The Handy app opens — speak your dictation
6. The app closes and your text appears in Notes

---

## 7. TestFlight Distribution

Requires an **Apple Developer Program** membership ($99/yr).

### Setup in App Store Connect

1. Log in to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **+** → **New App**
3. Platform: **iOS**
4. Name: `Handy`
5. Bundle ID: `com.handy.handy-app` (must match your signed bundle ID)
6. SKU: any unique string (e.g. `handy-ios-001`)
7. Click **Create**

### Archive and upload

In Xcode:

1. Select the **Handy** scheme
2. Set destination to **Any iOS Device (arm64)**
3. **Product → Archive**
4. When Archive Organizer opens, click **Distribute App**
5. Select **TestFlight & App Store** → Next
6. Select **Upload** → Next
7. Leave all options at defaults → Next → Upload

### Invite testers

1. In App Store Connect → your app → **TestFlight**
2. Wait for build processing (~5–15 minutes, Apple runs automated checks)
3. Under **Internal Testing**: add testers from your team (up to 100)
4. Under **External Testing**: click **+** to create a group, add emails (up to 10,000)
5. Testers receive an email with a TestFlight link

---

## 8. App Store Submission

### Before submitting

- [ ] App icon provided in all required sizes (already in `Assets.xcassets`)
- [ ] Privacy Policy URL ready (required — app accesses microphone)
- [ ] Support URL ready
- [ ] Screenshots for iPhone 6.7" display (iPhone 15 Pro Max size) taken
- [ ] App description written

### Required privacy declarations

In App Store Connect → your app → **App Privacy**, you must declare:

| Data type | Collected | Linked to user | Used for tracking |
|---|---|---|---|
| Audio data | No (processed on-device, never uploaded) | No | No |
| User-generated content (transcriptions) | No (stored locally only) | No | No |

### Info.plist privacy strings (already in code)

The following descriptions are already set in `Handy/Resources/Info.plist`:
- `NSMicrophoneUsageDescription` — used to explain microphone access on first launch
- `NSSpeechRecognitionUsageDescription` — used when Apple Speech engine is active

### Submit for review

1. In App Store Connect → your app → **App Store** tab
2. Click the `+` next to iOS App
3. Fill in: Version number, What's New, Screenshots, Description, Keywords
4. Under **Build**: select your uploaded build
5. Under **App Review Information**: add a note explaining the keyboard extension requires Full Access
6. Click **Submit for Review**

> Apple typically reviews apps in **24–48 hours**. Keyboard extensions sometimes require additional review time.

---

## 9. Troubleshooting

### "No such module 'WhisperKit'"
Xcode hasn't resolved packages yet. Go to **File → Packages → Resolve Package Versions**.

### Build fails with "Signing certificate not found"
In Xcode: **Preferences → Accounts** → sign in with your Apple ID → **Download Manual Profiles**.

### Keyboard extension not appearing in Settings
- Ensure you ran on a **physical device** (not Simulator)
- Bundle ID in `Shared/Constants.swift` must exactly match the keyboard target's bundle ID:
  ```swift
  static let keyboardBundleId = "com.handy.handy-app.keyboard"
  ```
- If you changed bundle IDs, rebuild and reinstall

### "Full Access" toggle in app always shows unchecked
This is the bug we fixed (issue #7). It resolves itself after you:
1. Enable Full Access in Settings
2. Open the Handy keyboard in any app and tap the mic button once (this opens the main app and writes the confirmation)
3. Re-open Settings in the Handy app — it will now show as confirmed

### Mic button shows "Flow session not active"
The main app is not running in the background. On iOS, the app must be open (or recently backgrounded) for the Flow session to be active. Tap the mic button again — it will automatically open the main app to start the session.

### WhisperKit model download fails
- Check you have enough storage (~150–500 MB depending on model)
- Models are downloaded from HuggingFace. If the download stalls, check your network connection.
- Try a smaller model (Base or Tiny) first

### App crashes on launch (older device)
Check your device's iOS version. iOS 18.0 is the minimum required. The app will crash on iOS 17 or earlier.

### `xcodegen generate` fails
Ensure you are in the repo root directory (where `project.yml` lives) when running the command. If you see YAML parse errors, run `git diff project.yml` to check for corruption.

---

## Quick Reference

```bash
# Generate project (run after any project.yml change)
xcodegen generate

# Open project
open Handy.xcodeproj

# Clean build folder (fixes most strange Xcode errors)
# Xcode: Product → Clean Build Folder (Cmd+Shift+K)
```

Bundle IDs: `com.handy.handy-app` / `.keyboard` / `.widget` / `.share`
App Group: `group.com.handy.shared`
Min iOS: 18.0 | Swift: 6.0 | Xcode: 16+
