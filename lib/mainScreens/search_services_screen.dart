import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Services'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Haircut'),
            onTap: () {
              Navigator.pop(context, 'haircut');
            },
          ),
          ListTile(
            title: const Text('Eyebrow'),
            onTap: () {
              Navigator.pop(context, 'eyebrow');
            },
          ),
          ListTile(
            title: const Text('Nail Art'),
            onTap: () {
              Navigator.pop(context, 'nailart');
            },
          ),
          // Add more service options as needed
        ],
      ),
    );
  }
}
