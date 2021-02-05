import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:logger/logger.dart';

const name = String.fromEnvironment('APP_NAME', defaultValue: 'unknownName');
const suffix =
    String.fromEnvironment('APP_SUFFIX', defaultValue: 'unknownSuffix');
const env = String.fromEnvironment('APP_ENV', defaultValue: 'unknownEnv');

Flavor get appFlavor => FlavorExtension.fromString(env);

enum Flavor {
  dev,
  stg,
  prod,
}

extension FlavorExtension on Flavor {
  String get projectID {
    switch (this) {
      // FIXME(you): project id
      case Flavor.dev:
        return 'project-dev';
      case Flavor.stg:
        return 'project-stg';
      case Flavor.prod:
        return 'project-prod';
    }
    throw FallThroughError();
  }

  static Flavor fromString(String value) {
    switch (value) {
      case 'dev':
        return Flavor.dev;
      case 'stg':
        return Flavor.stg;
      case 'prod':
        return Flavor.prod;
    }
    throw FallThroughError();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _validateProjectId();

  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(kReleaseMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  if (Platform.isIOS) {
    // FIXME: (you) fix appId
    await FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  } else if (Platform.isAndroid) {
    // FIXME: (you) fix appId
    await FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  }

  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          child: MyApp(),
        ),
      );
    },
    FirebaseCrashlytics.instance.recordError,
  );
}

void _validateProjectId() {
  final options = Firebase.app().options;
  if (appFlavor.projectID != options.projectId) {
    throw AssertionError(
      'expect the ProjectID for this flavor to be ${appFlavor.projectID} '
      'but, the actual ProjectID is ${options.projectId}',
    );
  }
}

class MyApp extends StatefulHookWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: useProvider(myRouterProvider).onGenerateRoute,
      navigatorKey: useProvider(myRouterProvider).navigatorKey,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: _analytics),
      ],
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
      ],
    );
  }

    
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
}

class MyRouter {
  MyRouter(this.reader);

  final navigatorKey = GlobalKey<NavigatorState>();

  final Reader reader;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text('hello'),
        ),
      ),
      settings: const RouteSettings(
        name: 'name',
      ),
    );
  }
}

final logger = Logger(
  output: _ConsoleOutputWithCrashlytics(),
  printer: appFlavor == Flavor.prod && kReleaseMode
      ? MyCrashlyticsLogPrinter()
      : PrettyPrinter(
          colors: false,
          printTime: true,
          errorMethodCount: 4,
        ),
  filter: _LogFilter(),
);

class MyCrashlyticsLogPrinter extends LogPrinter {
  static final levelPrefixes = {
    Level.verbose: '[V]',
    Level.debug: '[D]',
    Level.info: '[I]',
    Level.warning: '[W]',
    Level.error: '[E]',
    Level.wtf: '[WTF]',
  };

  @override
  List<String> log(LogEvent event) {
    final message = 'MESSAGE: ${_stringifyMessage(event.message)}';
    final errorString = '${event.error}';
    final object = errorString != 'null' && errorString.isNotEmpty
        ? 'OBJECT: ${event.error}'
        : '';

    final time = 'TIME: ${DateTime.now().toIso8601String()}';
    final traceRawString =
        event.stackTrace.toString().split('\n').take(4).toString();
    final trace = 'STACKTRACE: $traceRawString';
    return ['${levelPrefixes[event.level]}  $time  $message  $object  $trace'];
  }

  String _stringifyMessage(dynamic message) {
    if (message is Map || message is Iterable) {
      const encoder = JsonEncoder.withIndent(null);
      return encoder.convert(message);
    } else {
      return message.toString();
    }
  }
}

extension LoggerExtension on Logger {
  void debug(String message, dynamic object, StackTrace stackTrace) {
    logger.d(message, object, stackTrace);
  }

  void info(String message, dynamic object, StackTrace stackTrace) {
    logger.i(message, object, stackTrace);
  }

  void warning(String message, dynamic error, StackTrace stackTrace) {
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError('$message, $error', stackTrace);
    }
    logger.w(message, error, stackTrace);
  }

  void error(String message, dynamic error, StackTrace stackTrace) {
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError('$message, $error', stackTrace);
    }
    logger.e(message, error, stackTrace);
  }
}

class _LogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class _ConsoleOutputWithCrashlytics extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (appFlavor == Flavor.prod && kReleaseMode) {
      switch (event.level) {
        case Level.nothing:
        case Level.verbose:
        case Level.debug:
        case Level.info:
        case Level.warning:
          break;
        case Level.error:
        case Level.wtf:
          event.lines.forEach(print);
          break;
      }
    } else {
      event.lines.forEach(print);
    }
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.log(event.lines.toString());
    }
  }
}

final myRouterProvider = Provider<MyRouter>(
  (ref) => MyRouter(ref.read),
);
