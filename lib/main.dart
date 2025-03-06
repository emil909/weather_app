import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String weatherDescription = 'Fetching weather...';
  String locationName = 'Fetching location...';
  String weatherIconCode = '';
  List<Forecast> forecastList = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    Position position = await Geolocator.getCurrentPosition();
    final apiKey = '4ed0a0e6e768af9ca043ec6d88be9149';
    final lat = position.latitude.toString();
    final lon = position.longitude.toString();

    final weatherResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

    if (weatherResponse.statusCode == 200) {
      final weatherData = json.decode(weatherResponse.body);
      setState(() {
        weatherDescription = weatherData['weather'][0]['description'];
        locationName = weatherData['name'];
        weatherIconCode = weatherData['weather'][0]['icon'];
      });
    }

    // Fetch forecast data
    final forecastResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

    if (forecastResponse.statusCode == 200) {
      final forecastData = json.decode(forecastResponse.body);
      setState(() {
        forecastList = (forecastData['list'] as List)
            .map((item) => Forecast.fromJson(item))
            .toList();
      });
    }
  }

  Color _getBackgroundColor() {
    if (weatherIconCode.contains('01')) return Colors.blue[300]!;
    if (weatherIconCode.contains('02')) return Colors.lightBlue[200]!;
    if (weatherIconCode.contains('03') || weatherIconCode.contains('04')) {
      return Colors.grey[400]!;
    }
    if (weatherIconCode.contains('09') || weatherIconCode.contains('10')) {
      return Colors.blueGrey[600]!;
    }
    if (weatherIconCode.contains('11')) return Colors.deepPurple;
    if (weatherIconCode.contains('13')) return Colors.blueGrey[200]!;
    if (weatherIconCode.contains('50')) return Colors.grey[500]!;
    return Colors.blueAccent;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        color: _getBackgroundColor(),
        child: Center(
          child: _selectedIndex == 0
              ? CurrentWeather(
            locationName: locationName,
            weatherDescription: weatherDescription,
            weatherIconCode: weatherIconCode,
          )
              : ForecastTab(forecastList: forecastList),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: 'Current'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Forecast'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CurrentWeather extends StatelessWidget {
  final String locationName;
  final String weatherDescription;
  final String weatherIconCode;

  const CurrentWeather({
    super.key,
    required this.locationName,
    required this.weatherDescription,
    required this.weatherIconCode,
  });

  IconData _getWeatherIcon() {
    switch (weatherIconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.nights_stay;
      case '02d':
      case '02n':
        return Icons.cloud_queue;
      case '03d':
      case '03n':
        return Icons.cloud;
      case '04d':
      case '04n':
        return Icons.cloudy_snowing;
      case '09d':
      case '09n':
        return Icons.grain;
      case '10d':
      case '10n':
        return Icons.beach_access;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: locationName == 'Fetching location...' ? 0.0 : 1.0,
      duration: const Duration(seconds: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            locationName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Icon(
              _getWeatherIcon(),
              key: ValueKey(weatherIconCode),
              size: 100,
              color: Colors.yellowAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weatherDescription,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class ForecastTab extends StatelessWidget {
  final List<Forecast> forecastList;

  const ForecastTab({super.key, required this.forecastList});

  Map<String, List<Forecast>> _groupForecastsByDay(List<Forecast> forecasts) {
    final groupedForecasts = <String, List<Forecast>>{};
    for (final forecast in forecasts) {
      final day = DateFormat('EEEE, dd MMM').format(forecast.dateTime);
      groupedForecasts.putIfAbsent(day, () => []).add(forecast);
    }
    return groupedForecasts;
  }

  @override
  Widget build(BuildContext context) {
    if (forecastList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final groupedForecasts = _groupForecastsByDay(forecastList);

    return ListView.builder(
      itemCount: groupedForecasts.length,
      itemBuilder: (context, index) {
        final day = groupedForecasts.keys.elementAt(index);
        final forecastsForDay = groupedForecasts[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                day,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...forecastsForDay.map((forecast) => ListTile(
              leading: const Icon(Icons.cloud),
              title: Text(DateFormat('HH:mm').format(forecast.dateTime)),
              subtitle: Text(forecast.description),
            )),
            const Divider(),
          ],
        );
      },
    );
  }
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Weather App created for 1DV535 - Linnaeus University\nBy Emil Thedéen',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

class Forecast {
  final String description;
  final DateTime dateTime;

  Forecast({required this.description, required this.dateTime});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      description: json['weather'][0]['description'],
      dateTime: DateTime.parse(json['dt_txt']),
    );
  }
}
