import 'package:carbon_foodprint/instagram_util.dart';
import 'package:carbon_foodprint/pages/evaluation_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // MyApp();

  // final FirebaseMessaging firebaseMessaging;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final InstagramClient client = InstagramClient(username: 'kolja.es');

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    firebaseMessaging.getToken().then((value) => print(value));

    firebaseMessaging.configure(
      onLaunch: _handleNotification,
      onMessage: _handleNotification,
      onResume: _handleNotification,
    );

    // The FCM token can be used for testing messages.
    firebaseMessaging.getToken().then((value) => print(value));
  }

  Future<void> _handleNotification(Map<dynamic, dynamic> message) async {
    print(message);
    final imageUrl = message['data']['img'];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EvaluationPage(imageUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => print(await widget.client.getMostRecentPostUrl()),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
