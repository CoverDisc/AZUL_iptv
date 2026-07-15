# App Store Review Notes template

Replace every bracketed placeholder before submission.

## App purpose

This app is a media player for users who already have credentials for an authorized video service. The app does not sell subscriptions, provide channel packages, create accounts for paid services, or include bundled media catalogs.

## Login and service code

The login screen asks for:

- Service code
- Username
- Password

The service code is not a purchase code, activation key, coupon, or payment mechanism. It is a configuration identifier that allows the app to retrieve the correct API endpoint for an existing authorized service account.

The configuration is retrieved from our Firebase backend using Firebase App Check. The backend returns configuration data only; it does not download or execute code and it does not change the native features of the app.

## Review access

Use the following review credentials:

```text
Service code: [REVIEW_CODE]
Username: [REVIEW_USERNAME]
Password: [REVIEW_PASSWORD]
```

The review account will remain active throughout the review period and provides access to all user-facing features.

## Content rights

[LEGAL_ENTITY_NAME] is authorized to provide access to the services and media made available to the review account. Supporting agreements or authorization documents can be supplied upon request.

The app does not permit downloading or exporting third-party media.

## Purchases

There are no purchases, subscription sales, payment links, or calls to action directing users to purchase digital content outside the app. Users can only access an account and content they previously obtained from an authorized provider.

## Firebase and failover

Firebase is used to resolve the service code to an ordered list of authorized API endpoints. Multiple endpoints are used for availability and disaster recovery. This mechanism does not unlock additional app functionality and does not hide features from App Review.

## Privacy

Privacy policy: [PUBLIC_PRIVACY_POLICY_URL]
Support URL: [PUBLIC_SUPPORT_URL]

The privacy policy explains the use of Firebase, App Check, local credential storage, diagnostics, analytics, and advertising SDKs included in the submitted build.

## Contact

Review contact name: [NAME]
Review contact email: [EMAIL]
Review contact phone: [PHONE]
