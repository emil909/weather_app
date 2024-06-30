import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  fetchWeatherData();
  runApp(const MyApp());
}
void fetchWeatherData() async {
  final apiKey = '4ed0a0e6e768af9ca043ec6d88be9149';
  final lat = '59.401570';
  final lon = '13.569710';
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Parse the JSON response and display the weather data
    print(response.body);
  } else {
    // Handle errors
    print('Request failed with status: ${response.statusCode}.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.green,
        title: Text("Weather"),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Current weather',
            ),
            Text( "hej",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
