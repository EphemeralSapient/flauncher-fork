import 'package:flauncher/actions.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/ticker_model.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'flauncher.dart';
import 'flauncher_channel.dart';

class FLauncherApp extends StatelessWidget {
  final SharedPreferences _sharedPreferences;
  final ImagePicker _imagePicker;
  final FLauncherChannel _fLauncherChannel;
  final FLauncherDatabase _fLauncherDatabase;

  static const MaterialColor _swatch = MaterialColor(0xFF011526, <int, Color>{
    50: Color(0xFF36A0FA),
    100: Color(0xFF067BDE),
    200: Color(0xFF045CA7),
    300: Color(0xFF033662),
    400: Color(0xFF022544),
    500: Color(0xFF011526),
    600: Color(0xFF000508),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  });

  const FLauncherApp(
    this._sharedPreferences,
    this._imagePicker,
    this._fLauncherChannel,
    this._fLauncherDatabase, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => SettingsService(_sharedPreferences),
        lazy: false,
      ),
      ChangeNotifierProvider(
        create: (_) => AppsService(_fLauncherChannel, _fLauncherDatabase),
      ),
      ChangeNotifierProxyProvider<SettingsService, WallpaperService>(
        create: (_) => WallpaperService(_imagePicker, _fLauncherChannel),
        update:
            (_, settingsService, wallpaperService) =>
                wallpaperService!..settingsService = settingsService,
      ),
      Provider<TickerModel>(create: (context) => TickerModel(null)),
    ],
    child: MaterialApp(
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.select):
            const ActivateIntent(),
        const SingleActivator(
          LogicalKeyboardKey.gameButtonB,
        ): const PrioritizedIntents(
          orderedIntents: [DismissIntent(), BackIntent()],
        ),
      },
      actions: {
        ...WidgetsApp.defaultActions,
        DirectionalFocusIntent: SoundFeedbackDirectionalFocusAction(context),
      },
      title: 'FLauncher',
      theme: ThemeData(
        brightness: Brightness.dark,
        cardColor: _swatch[300],
        canvasColor: _swatch[300],
        scaffoldBackgroundColor: _swatch[400],
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        typography: Typography.material2021(),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: Typography.material2021().white.bodyMedium,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: _swatch[200],
          selectionHandleColor: _swatch[200],
        ),
        dialogTheme: DialogTheme(backgroundColor: _swatch[400]),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: _swatch,
          brightness: Brightness.dark,
        ).copyWith(secondary: _swatch[200], surface: _swatch[400]),
      ),
      home: Builder(
        builder:
            (context) => WillPopScope(
              onWillPop: () async {
                final shouldPop = await shouldPopScope(context);
                if (!shouldPop) {
                  context.read<AppsService>().startAmbientMode();
                }
                return shouldPop;
              },
              child: Actions(
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (intent) {
                      debugPrint('Select button pressed!');
                      return const ActivateIntent();
                    },
                  ),
                  BackIntent: BackAction(context, systemNavigator: true),
                },

                child: FLauncher(),
              ),
            ),
      ),
    ),
  );
}
