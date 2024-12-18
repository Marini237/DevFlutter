import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _city = 'Loading...';
  String _temperature = 'Loading...';
  String _error = '';
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

  Future<void> fetchWeatherData() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      String city = await _locationService.getCityFromCoordinates(position);
      Map<String, dynamic> weatherData =
          await _weatherService.fetchWeatherData(city);
      double temperature = weatherData['current']['temp_c'];
      setState(() {
        _city = city;
        _temperature = temperature.toStringAsFixed(2);
        _error = '';
      });
    } catch (e) {
      setState(() {
        _city = 'Error';
        _temperature = 'Error';
        _error = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('City: $_city', style: TextStyle(fontSize: 24)),
          Text('Temperature: $_temperature°C', style: TextStyle(fontSize: 24)),
          if (_error.isNotEmpty) ...[
            SizedBox(height: 20),
            Text('Error: $_error', style: TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
