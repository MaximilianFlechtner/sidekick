import 'package:flutter/material.dart';
import 'package:sidekick/screens/packages_scenes/most_used_section.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: TabBar(
            tabs: [
              Tab(text: 'Most Used Packages'),
              Tab(text: 'Trending'),
              Tab(text: 'Popular'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const MostUsedSection(),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }
}
