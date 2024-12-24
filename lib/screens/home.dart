import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Firebase Realtime Database reference for 'Ultrasonic/distance'
  final DatabaseReference databaseRef =
  FirebaseDatabase.instance.ref("Ultrasonic/distance");

  // To handle pull-to-refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a Stack to add a background gradient
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.teal[100]!
                      : Colors.teal[900]!,
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.teal[300]!
                      : Colors.teal[700]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main Content with SafeArea
          SafeArea(
            child: Column(
              children: [
                // AppBar Replacement with more customization
                _buildCustomAppBar(),
                Expanded(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      setState(() {}); // Refresh the StreamBuilder
                    },
                    child: Center(
                      child: StreamBuilder<DatabaseEvent>(
                        stream: databaseRef.onValue, // Listen to the distance node
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingWidget(); // Custom loading indicator
                          }
                          if (snapshot.hasError) {
                            // Log the error and display a user-friendly message
                            debugPrint("Firebase Error: ${snapshot.error}");
                            return ErrorWidgetDisplay(
                              message:
                              "Oops! Something went wrong while fetching data.",
                            );
                          }
                          if (snapshot.hasData &&
                              snapshot.data!.snapshot.value != null) {
                            // Extract the distance value
                            var distance = snapshot.data!.snapshot.value.toString();
                            return DistanceCard(distance: distance); // Display in card
                          } else {
                            return ErrorWidgetDisplay(
                              message: "No data available at the moment.",
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom AppBar Widget
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal,
            Colors.tealAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_damage,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 10),
          Text(
            "Ultrasonic Distance",
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ],
      ),
    );
  }
}

// Custom Loading Widget with Animated Spinner
class LoadingWidget extends StatefulWidget {
  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for rotation
    _controller =
    AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    // Dispose the controller to free resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: RotationTransition(
        turns: _animation,
        child: Icon(
          Icons.autorenew,
          size: 60,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// Custom Error Widget with Enhanced Styling
class ErrorWidgetDisplay extends StatelessWidget {
  final String message;

  const ErrorWidgetDisplay({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 60,
          ),
          SizedBox(height: 20),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Trigger a refresh
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Retrying...")),
              );
              // Here you might want to implement a retry mechanism
            },
            icon: Icon(Icons.refresh),
            label: Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget to display the distance inside a beautiful card
class DistanceCard extends StatelessWidget {
  final String distance;

  const DistanceCard({Key? key, required this.distance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.85;

    return Card(
      elevation: 10,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? Colors.teal[50]!
                  : Colors.teal[800]!,
              Theme.of(context).brightness == Brightness.light
                  ? Colors.teal[100]!
                  : Colors.teal[700]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sensors,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              "Current Distance",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 15),
            Text(
              "$distance cm",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 10),
            // Additional UI elements can be added here
            // For example, a trend indicator or historical data
          ],
        ),
      ),
    );
  }
}
