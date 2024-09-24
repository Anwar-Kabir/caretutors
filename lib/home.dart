import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String apiUrl = 'https://api.nasa.gov/planetary/apod';
  String apiKey = '18QBwoiRpbFgeYBSl3PxFHi2aoJjrt7lIindJfng';
  String selectedDate = '';
  String imageUrl = '';
  bool isLoading = false;

  // Default placeholder image
  String defaultImageUrl = 'https://via.placeholder.com/600x400.png?text=NASA+APOD';

  Future<void> fetchApodData() async {
    if (selectedDate.isEmpty) return; 

    setState(() {
      isLoading = true; 
      imageUrl = defaultImageUrl; 
    });

    try {
      var response = await http.get(
        Uri.parse('$apiUrl?api_key=$apiKey&date=$selectedDate'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          imageUrl = data['hdurl']; 
        });
      } else {
        throw Exception('Failed to load image');
      }
    } catch (error) {
      setState(() {
        imageUrl = defaultImageUrl; 
      });
      print(error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked.toString().split(' ')[0]; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NASA APOD"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _pickDate(context),
            child: Text("Pick a Date"),
          ),
          SizedBox(height: 20),
          Text(
            selectedDate.isEmpty ? 'No Date Selected' : 'Selected Date: $selectedDate',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchApodData,
            child: Text("Submit"),
          ),
          SizedBox(height: 20),
          isLoading
              ? CircularProgressIndicator()
              : imageUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(imageUrl),
                    )
                  : CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(defaultImageUrl),
                    ),
        ],
      ),
    );
  }
}