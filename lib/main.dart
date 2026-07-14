import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:mbark_iptv/repository/api/api.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'helpers/helpers.dart';
import 'helpers/translations.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/categories/channels/channels_bloc.dart';
import 'logic/blocs/categories/live_caty/live_caty_bloc.dart';
import 'logic/blocs/categories/movie_caty/movie_caty_bloc.dart';
import 'logic/blocs/categories/series_caty/series_caty_bloc.dart';
import 'logic/cubits/favorites/favorites_cubit.dart';
import 'logic/cubits/settings/settings_cubit.dart';
import 'logic/cubits/video/video_cubit.dart';
import 'logic/cubits/watch/watching_cubit.dart';
import 'presentation/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ar';
  await GetStorage.init();
  await GetStorage.init("favorites");
  if (showAds) {
    MobileAds.instance.initialize();
  }

  runApp(MyApp(
    iptv: IpTvApi(),
    authApi: AuthApi(),
    watchingLocale: WatchingLocale(),
    favoriteLocale: FavoriteLocale(),
  ));
}

class MyApp extends StatefulWidget {
  final IpTvApi iptv;
  final AuthApi authApi;
  final WatchingLocale watchingLocale;
  final FavoriteLocale favoriteLocale;
  const MyApp(
      {super.key,
      required this.iptv,
      required this.authApi,
      required this.watchingLocale,
      required this.favoriteLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (BuildContext context) => AuthBloc(widget.authApi),
          ),
          BlocProvider<LiveCatyBloc>(
            create: (BuildContext context) => LiveCatyBloc(widget.iptv),
          ),
          BlocProvider<ChannelsBloc>(
            create: (BuildContext context) => ChannelsBloc(widget.iptv),
          ),
          BlocProvider<MovieCatyBloc>(
            create: (BuildContext context) => MovieCatyBloc(widget.iptv),
          ),
          BlocProvider<SeriesCatyBloc>(
            create: (BuildContext context) => SeriesCatyBloc(widget.iptv),
          ),
          BlocProvider<VideoCubit>(
            create: (BuildContext context) => VideoCubit(),
          ),
          BlocProvider<SettingsCubit>(
            create: (BuildContext context) => SettingsCubit(),
          ),
          BlocProvider<WatchingCubit>(
            create: (BuildContext context) =>
                WatchingCubit(widget.watchingLocale),
          ),
          BlocProvider<FavoritesCubit>(
            create: (BuildContext context) =>
                FavoritesCubit(widget.favoriteLocale),
          ),
        ],
        child: ResponsiveSizer(
          builder: (context, orient, type) {
            return GetMaterialApp(
              title: kAppName,
              theme: MyThemApp.themeData(context),
              debugShowCheckedModeBanner: false,
              initialRoute: "/",
              translations: AppTranslations(),
              locale: const Locale('ar'),
              fallbackLocale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              builder: (context, child) {
                return Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: child!,
                );
              },
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              getPages: [
                GetPage(name: screenSplash, page: () => const SplashScreen()),
                GetPage(name: screenWelcome, page: () => const WelcomeScreen()),
                GetPage(name: screenIntro, page: () => const IntroScreen()),
                GetPage(
                    name: screenLiveCategories,
                    page: () => const LiveChannelsScreen(catyId: "")),
                GetPage(
                    name: screenRegister, page: () => const RegisterScreen()),
                GetPage(
                    name: screenRegisterTv, page: () => const RegisterUserTv()),
                GetPage(
                    name: screenMovieCategories,
                    page: () => const MovieChannels(catyId: "")),
                GetPage(
                    name: screenSeriesCategories,
                    page: () => const SeriesChannels(catyId: "")),
                GetPage(
                    name: screenSettings, page: () => const SettingsScreen()),
                GetPage(
                    name: screenFavourite, page: () => const FavouriteScreen()),
                GetPage(name: screenCatchUp, page: () => const CatchUpScreen()),
              ],
            );
          },
        ),
      ),
    );
  }
}
