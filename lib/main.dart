import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {int _selectedIndex = 0;
String weatherDescription = 'Fetching weather...';
String locationName = 'Fetching location...';

@override
void initState() {
  super.initState();
  fetchWeatherData();
}

Future<void> fetchWeatherData() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        weatherDescription = 'Location permissions are denied';
      });
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    setState(() {
      weatherDescription =
      'Location permissions are permanently denied, we cannot request permissions.';
    });
    return;
  }

  Position position = await Geolocator.getCurrentPosition();

  final apiKey = '4ed0a0e6e768af9ca043ec6d88be9149';
  final lat = position.latitude.toString();
  final lon = position.longitude.toString();
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final weather = jsonData['weather'][0]['description'];
    final name = jsonData['name'];
    setState(() {
      weatherDescription = weather;
      locationName = name;
    });
  } else {
    setState(() {
      weatherDescription = 'Failed to fetch weather';
      locationName = 'Failed to fetch location';
    });
    print('Request failed with status: ${response.statusCode}.');
  }
}

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.green,
      title: Text(widget.title),
    ),
    body: Center(
      child: _selectedIndex == 0
          ? CurrentWeather(
        locationName: locationName,
        weatherDescription: weatherDescription,
      )
          : _selectedIndex == 1
          ? ForecastTab()
          : AboutTab(),
    ),
    bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.wb_sunny),
          label: 'Current',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Forecast',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      onTap: _onItemTapped,
    ),
  );
}
}

class CurrentWeather extends StatelessWidget {
  final String locationName;
  final String weatherDescription;

  const CurrentWeather({
    super.key,
    required this.locationName,
    required this.weatherDescription,
  });@override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          locationName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        const Text(
          'Current weather',
        ),
        Text(
          weatherDescription,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class ForecastTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Forecast tab'),
    );
  }
}

class AboutTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is an app that is developed for the course 1DV535 at Linneaus university using Flutter and the OpenWeatherMap API. Developed by Emil Thedéen'),
    );
  }
}