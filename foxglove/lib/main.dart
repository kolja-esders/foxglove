// import 'package:carbon_foodprint/instagram_util.dart';
import 'dart:convert';

import 'package:carbon_foodprint/pages/evaluation_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // final InstagramClient client = InstagramClient(username: 'kolja.es');

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
    final id = message['data']['id'];

    final res = await http.get('http://48d6a3f4ac35.ngrok.io/id?id=$id');
    print(res.body);

    Map<String, dynamic> data = jsonDecode(res.body);
    print(data);
    final instructions = data['instructions'] as List<String>;
    final title = data['title'] as String;
    print(instructions);
    print(title);

    final args = EvaluationPageArgs(
      imageUrl: message['data']['img'],
      instructions: instructions,
      alternatives: {
        'rice': [
          Ingredient('caciocavallo', 1.4556092525771795),
          Ingredient('tonkatsu_sauce', 1.1728355761916132),
        ]
      },
      ingredients: [
        Ingredient('rice', 3.7423330502115872),
        Ingredient('nori', 2.8853163760624394),
      ],
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EvaluationPage(args)),
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
        // onPressed: () async => print(await widget.client.getMostRecentPostUrl()),
        onPressed: () async => print(''),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
