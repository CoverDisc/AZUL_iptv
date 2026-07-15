# Privacy Policy

Last updated: July 15, 2026

This privacy policy describes how the AZUL IPTV media-player application processes information.

## Purpose of the app

The app is a media player for users who already have access credentials for an authorized third-party video service. The app does not sell subscriptions, provide channel packages, or create third-party service accounts.

## Information entered by the user

The app asks the user to enter:

- a service configuration code;
- a username;
- a password.

The service code is sent to a Firebase Cloud Function to retrieve the endpoint configuration associated with that code. The Firebase provisioning request does not include the third-party service username or password.

The username and password are sent directly to the selected third-party service endpoint to authenticate the user's existing account and retrieve media data. The operator of that third-party service processes this information under its own terms and privacy policy.

## Local storage

The app stores the current service configuration, account response, favorites, watch history, and preferences locally on the device so that the app can remain signed in and restore the user's experience.

The current implementation uses application-local storage. Users can remove the saved account from the app by using the logout function. Removing the app also removes its local application data according to iOS behavior.

## Firebase

The app uses the following Firebase services:

- Firebase Cloud Functions, to resolve a service code;
- Cloud Firestore, accessed only by the trusted Cloud Function, to store service profiles;
- Firebase App Check with Apple's App Attest, to help protect the provisioning backend from unauthorized clients and abuse.

Firebase may process technical information required to provide and secure these services, such as App Check attestation data, network information, timestamps, and diagnostic information. Google's Firebase privacy and security terms apply to that processing.

## Media and third-party services

Channel metadata, images, electronic program guide data, movies, series, and streams are requested from the third-party service selected by the user's service code. Requests may disclose the user's IP address and standard network information to that service and to hosts serving media artwork.

The app does not upload or sell the user's viewing history. Favorites and watch history are stored locally unless a future version clearly discloses another behavior and obtains any legally required consent.

## Advertising and analytics

Advertising is disabled in the current release configuration. If advertising, analytics, crash reporting, or tracking is enabled in a future release, this policy and the App Store privacy disclosures must be updated before distribution. Where required, the app will request permission through Apple's App Tracking Transparency framework.

## Data sharing

The app does not sell personal information. Information is disclosed only as necessary to:

- resolve the service configuration through Firebase;
- authenticate and communicate with the user's selected third-party service;
- comply with law or protect users, the service, or legal rights.

## Data retention and deletion

Provisioning configuration and account information remain on the device until the user logs out, clears application data, or removes the app. Third-party providers may retain authentication and server logs according to their own policies.

To request support or report a privacy concern, open an issue in the project's public support repository without including passwords, access credentials, private playlist links, or other sensitive information.

## Children

The app is not directed to children. Users must comply with the age restrictions and content rules of their third-party service. The app's parental filtering features do not replace legally required age verification or content ratings.

## Security

Reasonable technical measures are used, including HTTPS for Firebase and Firebase App Check. No transmission or storage method is completely secure. Authorized service operators should provide HTTPS endpoints. Users should not use credentials on untrusted or unauthorized services.

## Changes

This policy may be updated when application features, service providers, or legal requirements change. The updated date at the top of this page will identify the latest revision.

## Contact

Support and privacy requests:

https://github.com/CoverDisc/AZUL_iptv/issues
