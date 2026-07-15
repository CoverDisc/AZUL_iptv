# Firebase service-code provisioning

The app no longer asks the user for a server URL. It asks for:

- service code
- username
- password

The service code is resolved by a Firebase callable Cloud Function. The Cloud Function reads exactly one Firestore document and returns the enabled Xtream-compatible endpoints ordered by priority.

## Architecture

```text
Flutter app
  -> Firebase App Check
  -> callable function: resolveServerProfile
  -> Firestore document: serverProfiles/{SERVICE_CODE}
  -> ordered list of authorized service endpoints
  -> Xtream authentication with automatic login failover
```

Remote Config is useful for non-sensitive flags such as maintenance mode, minimum supported version, or user-facing notices. It is intentionally not used as the complete server directory because every Remote Config value delivered to a client should be considered readable by that client.

## 1. Create and connect the Firebase project

Install the Firebase CLI and FlutterFire CLI, then authenticate:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

From the repository root:

```bash
flutterfire configure
```

Register the real iOS Bundle Identifier that will be used in App Store Connect. The generated iOS Firebase configuration must match that Bundle Identifier.

For an Apple build, confirm that `ios/Runner/GoogleService-Info.plist` is included in the Runner target. Do not commit production secrets or service-account keys.

## 2. Create Firestore

Create a Firestore database in the same Firebase project. Add a document whose ID is the service code, for example:

```text
Collection: serverProfiles
Document ID: 036
```

Example document:

```json
{
  "enabled": true,
  "profileVersion": 1,
  "servers": [
    {
      "baseUrl": "https://primary-authorized-service.example",
      "priority": 1,
      "enabled": true
    },
    {
      "baseUrl": "https://backup-authorized-service.example",
      "priority": 2,
      "enabled": true
    }
  ]
}
```

Use HTTPS endpoints whenever possible. The service code is an identifier for an existing authorized service configuration. It must not be marketed or used as a purchase code, license key, or mechanism that secretly unlocks paid content.

## 3. Deploy Firestore rules and Cloud Function

Install backend dependencies:

```bash
cd firebase/functions
npm install
cd ../..
```

Associate the repository with the Firebase project:

```bash
firebase use --add
```

Deploy:

```bash
firebase deploy --only functions,firestore:rules
```

The mobile app expects the callable function:

```text
resolveServerProfile
```

in region:

```text
europe-west1
```

If another region is selected, update `_functionRegion` in `lib/repository/api/provisioning.dart` before release.

## 4. Configure Firebase App Check

In Firebase Console, register the iOS app with App Check and use App Attest. During development, use the Firebase debug provider according to the official Firebase instructions.

Do not enable Cloud Functions App Check enforcement until real-device requests appear as valid in the App Check metrics. The included Cloud Function sets `enforceAppCheck: true`; temporarily set it to `false` only during initial local configuration and restore it before production deployment.

## 5. Failover behavior

The app tries endpoints in ascending `priority` order.

It moves to the next endpoint for:

- connection timeout
- DNS or TLS transport failure
- unavailable endpoint
- malformed/non-Xtream response

It does not use failover to bypass account restrictions. If an endpoint returns a valid Xtream response with an unauthenticated or inactive account, login stops and is rejected.

The last valid provisioning result is cached locally and can be used during a temporary Firebase outage. Adding, removing, disabling, or reprioritizing an endpoint in Firestore does not require a new App Store release.

## 6. App Store review preparation

A remotely resolved API endpoint is configuration data, not downloaded executable code. Nevertheless, App Review evaluates the complete behavior and business model, not only the implementation method.

Before submission:

1. The app must be fully functional for the reviewer.
2. Supply a working review service code and test credentials in App Review Notes.
3. State that the app is a media player for existing authorized accounts and does not sell or provide content.
4. Do not include buttons, text, or links that direct users to buy digital content outside Apple purchase rules.
5. Provide documentary authorization for every third-party service or media catalog if Apple requests it.
6. Do not hide features or provide a harmless review-only catalog that changes after approval.
7. Keep the service-code field visibly described as a configuration identifier, not an activation or purchase code.
8. Provide a privacy policy explaining Firebase, App Check, diagnostic data, credentials, and any analytics or advertising SDKs.
9. Prefer HTTPS and remove global ATS exceptions before submission when the authorized services support secure transport.

Apple approval can never be guaranteed in advance. The review team may reject an IPTV client when content rights, the business model, review access, or third-party authorization are unclear.
