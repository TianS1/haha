import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:revibook/config/app_config.dart';

import './config/router.dart';
import './config/theme.dart';
import './services/bmob.dart';
import './services/local.dart';
import './services/rong.dart';
import './view_models/app_view_model.dart';
import './view_models/circles_view_model.dart';
import './view_models/curr_user_view_model.dart';
import './view_models/interactions_view_model.dart';
import './view_models/systems_view_model.dart';
import './views/widgets/phoenix.dart';
import './views/widgets/pull_refresh.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // customize print
  if (kReleaseMode) {
    debugPrint = (String message, {int wrapWidth}) {};
  }

  AppConfig();
  // init service
  BmobService.init();
  ///RongService.init();
  await LocalService.init();

  runApp(
    Phoenix(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppViewModel>(
          create: (context) => AppViewModel(),
        ),
        ChangeNotifierProvider<CurrUserViewModel>(
          create: (context) => CurrUserViewModel(),
        ),
        ChangeNotifierProvider<CirclesViewModel>(
          create: (context) =>
              CirclesViewModel(context.read<CurrUserViewModel>().id),
        ),
        ChangeNotifierProvider<InteractionsViewModel>(
          create: (context) =>
              InteractionsViewModel(context.read<CurrUserViewModel>().id),
        ),
        ChangeNotifierProvider<SystemsViewModel>(
          create: (context) =>
              SystemsViewModel(context.read<CurrUserViewModel>().id),
        ),
      ],
      child: Builder(
        builder: (context) {
          return PullRefresh(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Revibook',
              theme: AppTheme.themeData,
              initialRoute:
                  Provider.of<CurrUserViewModel>(context, listen: false).hasUser
                      ? AppRouter.splash
                      : AppRouter.signIn,
              onGenerateRoute: AppRouter.generateRoute,
              localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                  const Locale('zh', 'CN'),
                  const Locale('en', 'US')
              ]
            ),
          );
        },
      ),
    );
  }
}
