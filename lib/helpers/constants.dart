part of 'helpers.dart';

const String kAppName = "عالمنا+";

// TODO: Show Ads (true / false)
const bool showAds = false;

const String kIconLive = "assets/images/live-stream.png";
const String kIconSeries = "assets/images/clapperboard.png";
const String kIconMovies = "assets/images/film-reel.png";
const String kIconSplash = "assets/images/icon.png";
const String kImageIntro = "assets/images/intro h.jpeg";

// These public pages must remain accurate and reachable during App Review.
const String kPrivacy =
    "https://github.com/CoverDisc/AZUL_iptv/blob/main/PRIVACY.md";
const String kContact = "https://github.com/CoverDisc/AZUL_iptv/issues";

const double sizeTablet = 950;

enum TypeCategory {
  all,
  live,
  movies,
  series,
}

Size getSize(BuildContext context) => MediaQuery.of(context).size;

bool isTv(BuildContext context) {
  return MediaQuery.of(context).size.width > sizeTablet;
}
