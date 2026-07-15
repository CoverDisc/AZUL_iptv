part of '../screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _serviceCode = TextEditingController();

  @override
  void dispose() {
    _serviceCode.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Get.textTheme.bodyMedium!.copyWith(
      color: Colors.white,
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Ink(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, stateSetting) {
            return SafeArea(
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthFailed) {
                    showWarningToast(
                      context,
                      'Accesso non riuscito',
                      'Controlla il codice servizio e le credenziali fornite dal tuo servizio autorizzato.',
                    );
                  } else if (state is AuthSuccess) {
                    context.read<LiveCatyBloc>().add(GetLiveCategories());
                    context.read<MovieCatyBloc>().add(GetMovieCategories());
                    context.read<SeriesCatyBloc>().add(GetSeriesCategories());
                    Get.offAndToNamed(screenWelcome);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return IgnorePointer(
                    ignoring: isLoading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                FontAwesomeIcons.chevronLeft,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                'Accesso servizio',
                                style: Get.textTheme.titleMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 1.h),
                                Image.asset(
                                  kIconSplash,
                                  width: .7.dp,
                                  height: .7.dp,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Inserisci i dati ricevuti dal tuo servizio.',
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.bodyLarge!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'L’app è un lettore multimediale e non fornisce canali, abbonamenti o contenuti.',
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.bodyMedium!.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                TextField(
                                  controller: _serviceCode,
                                  textCapitalization: TextCapitalization.characters,
                                  keyboardType: TextInputType.visiblePassword,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z0-9]'),
                                    ),
                                    LengthLimitingTextInputFormatter(12),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Codice servizio, es. 036',
                                    helperText:
                                        'Il codice identifica la configurazione del servizio; non è un codice acquisto.',
                                    helperMaxLines: 2,
                                    hintStyle: Get.textTheme.bodyMedium!.copyWith(
                                      color: Colors.grey,
                                    ),
                                    helperStyle: Get.textTheme.bodySmall!.copyWith(
                                      color: Colors.white60,
                                    ),
                                    suffixIcon: const Icon(
                                      FontAwesomeIcons.server,
                                      size: 18,
                                      color: kColorPrimary,
                                    ),
                                  ),
                                  style: style,
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: _username,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.username],
                                  decoration: InputDecoration(
                                    hintText: 'Username',
                                    hintStyle: Get.textTheme.bodyMedium!.copyWith(
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: const Icon(
                                      FontAwesomeIcons.solidUser,
                                      size: 18,
                                      color: kColorPrimary,
                                    ),
                                  ),
                                  style: style,
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: _password,
                                  obscureText: true,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: Get.textTheme.bodyMedium!.copyWith(
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: const Icon(
                                      FontAwesomeIcons.lock,
                                      size: 18,
                                      color: kColorPrimary,
                                    ),
                                  ),
                                  style: style,
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.circleInfo,
                                      color: Colors.white70,
                                      size: 12.sp,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Wrap(
                                        children: [
                                          Text(
                                            'Usando l’app accetti la ',
                                            style: Get.textTheme.bodyMedium!
                                                .copyWith(color: Colors.white70),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              final url = Uri.parse(kPrivacy);
                                              await launchUrl(
                                                url,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                            child: Text(
                                              'privacy policy.',
                                              style: Get.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: kColorPrimary
                                                    .withOpacity(.70),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: CardTallButton(
                            label: 'Accedi',
                            isLoading: isLoading,
                            onTap: () {
                              FocusScope.of(context).unfocus();

                              final username = _username.text.trim();
                              final password = _password.text;
                              final serviceCode =
                                  _serviceCode.text.trim().toUpperCase();

                              if (username.isEmpty ||
                                  password.isEmpty ||
                                  serviceCode.length < 3) {
                                showWarningToast(
                                  context,
                                  'Dati mancanti',
                                  'Inserisci codice servizio, username e password.',
                                );
                                return;
                              }

                              context.read<AuthBloc>().add(
                                    AuthRegister(
                                      username,
                                      password,
                                      serviceCode,
                                    ),
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
