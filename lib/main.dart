import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> dataList = [];
  StreamController streamController = StreamController.broadcast();

  @override
  void initState() {
    streamController = StreamController.broadcast();
    setupData();
    super.initState();
  }

  setupData() async {
    Stream stream = await getData()
      ..pipe(streamController);

    stream.listen((event) {
      setState(() => dataList.add(event));
    });
  }

  void dispose() {
    super.dispose();
    streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Multi-Item List"),
        ),
      ),
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: ((context, index) {
          return const SizedBox.shrink();
        }),
      ),
    );
  }
}

class Photo {
  final String url;
  final String title;

  Photo(this.url, this.title);

  Photo.fromJson(Map json)
      : url = json['url'],
        title = json['title'];
}

class Post {
  final String title;
  final String body;

  Post(this.title, this.body);

  Post.fromJson(Map json)
      : title = json['title'],
        body = json['body'];
}

Future<Stream> getData() async {
  final client = http.Client();

  Stream streamOne = LazyStream(() async => await getPhotos(client));
  Stream streamTwo = LazyStream(() async => await getPosts(client));

  return StreamGroup.merge([streamOne, streamTwo]).asBroadcastStream();
}

Future<Stream> getPhotos(http.Client client) async {
  const url = 'https://jsonplaceholder.typicode.com/photos';
  final request = http.Request('get', Uri.parse(url));

  http.StreamedResponse streamedResponse = await client.send(request);

  return streamedResponse.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .expand((e) => e as List)
      .map(
        (map) => Photo.fromJson(map),
      );
}

Future<Stream> getPosts(http.Client client) async {
  const url = 'https://jsonplaceholder.typicode.com/posts';
  final request = http.Request('get', Uri.parse(url));

  http.StreamedResponse streamedResponse = await client.send(request);

  return streamedResponse.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .expand((e) => e as List)
      .map(
        (map) => Photo.fromJson(map),
      );
}
