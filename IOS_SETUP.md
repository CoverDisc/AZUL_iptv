# iOS / iPhone setup

This branch prepares the Flutter project for an initial iPhone build targeting iOS 15 or later.

## Requirements

- macOS with a current stable Xcode release
- Flutter SDK compatible with Dart 3.5 or later
- CocoaPods
- An Apple Developer account for device signing and App Store distribution

## First build

```bash
flutter clean
flutter pub get
cd ios
pod deintegrate
pod install --repo-update
cd ..
open ios/Runner.xcworkspace
```

In Xcode, select the **Runner** target and configure:

1. Your Apple Developer Team.
2. A unique Bundle Identifier. Do not publish using `com.iptv.azul` unless you own it.
3. iOS Deployment Target 15.0 for Runner configurations.
4. Signing for Debug and Release.

Run on a physical iPhone before creating an archive:

```bash
flutter run
```

Create a release archive with:

```bash
flutter build ipa --release
```

## IPTV validation checklist

Test only streams and content for which you have authorization.

- Xtream Codes login over HTTPS
- HTTP server compatibility where legally required
- HLS/M3U8 live streams
- VOD playback and seeking
- background and foreground transitions
- portrait-to-landscape transitions
- audio volume and screen brightness controls
- expired or invalid credentials
- long-running playback and wakelock behavior

## App Store notes

The app must not include bundled channel lists, credentials, copyrighted artwork, or access to content that you are not authorized to distribute. Apple may request documentation proving rights to third-party services and media.

The existing `NSAllowsArbitraryLoads` setting is retained for compatibility with legacy IPTV endpoints. Before App Store submission, prefer HTTPS and replace the global exception with narrowly scoped ATS exceptions where possible.

The current Picture-in-Picture dependency was Android-only and has been removed. Native iOS PiP should be implemented separately only after the baseline iPhone player is stable.
