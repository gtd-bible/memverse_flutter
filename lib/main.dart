import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      final newCounter = _counter + 1;
      _counter = newCounter;
      _handleCounterEvent(newCounter);
    });
  }

  Future<void> _handleCounterEvent(int counterValue) async {
    switch (counterValue) {
      case 1:
        await _sendAnalyticsEvent('counter_event_1', {'message': 'First push - analytics only'});
        break;
      case 2:
        await _sendAnalyticsEvent('counter_event_2', {'message': 'Second push - sending NFE'});
        await _sendNonFatalException();
        break;
      case 3:
        await _sendAnalyticsEvent('counter_event_3', {
          'message': 'Third push - sending fatal crash',
        });
        await _sendFatalCrash();
        break;
      default:
        await _sendAnalyticsEvent('counter_event_$counterValue', {
          'message': 'Push #$counterValue - regular analytics',
        });
    }
  }

  Future<void> _sendAnalyticsEvent(String eventName, Map<String, Object> parameters) async {
    debugPrint('Sending analytics event: $eventName');
    await widget.analytics.logEvent(name: eventName, parameters: parameters);
    debugPrint('Analytics event sent: $eventName');
  }

  Future<void> _sendNonFatalException() async {
    debugPrint('Sending non-fatal exception to Crashlytics');
    try {
      throw Exception('Test non-fatal exception from counter event');
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(error, stack);
    }
    debugPrint('Non-fatal exception sent to Crashlytics');
  }

  Future<void> _sendFatalCrash() async {
    debugPrint('Sending fatal crash to Crashlytics');
    try {
      throw StateError('Test fatal crash from counter event');
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    debugPrint('Fatal crash sent to Crashlytics');
  }

  void _forceCrash() {
    debugPrint('Forcing fatal crash');
    FirebaseCrashlytics.instance.crash();
  }

  Future<void> _sendNFE() async {
    debugPrint('Sending non-fatal exception from button');
    try {
      throw Exception('Test NFE from button');
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(error, stack);
    }
    debugPrint('NFE sent from button');
  }

  Future<void> _call404API() async {
    debugPrint('Calling 404 API (typo URL)');
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/postsss'));
      debugPrint('404 API response: ${response.statusCode}');
    } catch (error) {
      debugPrint('404 API error: $error');
      await FirebaseCrashlytics.instance.recordError(
        '404 API call failed: $error',
        StackTrace.current,
      );
    }
  }

  Future<void> _call500API() async {
    debugPrint('Calling 500 API');
    try {
      final response = await http.get(Uri.parse('https://httpbin.org/status/500'));
      debugPrint('500 API response: ${response.statusCode}');
    } catch (error) {
      debugPrint('500 API error: $error');
      await FirebaseCrashlytics.instance.recordError(
        '500 API call failed: $error',
        StackTrace.current,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: .center,
            children: [
              const Text('You have pushed the button this many times:'),
              Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              const Text('Test Buttons (Counter behavior):'),
              const Text('1st push: analytics | 2nd push: NFE | 3rd push: crash'),
              const SizedBox(height: 32),
              const Text('Manual Test Buttons:'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _forceCrash, child: const Text('Force Crash')),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _sendNFE, child: const Text('Send NFE')),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _call404API, child: const Text('Call 404 API')),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _call500API, child: const Text('Call 500 API')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
