import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your custom AppColors
import 'package:tankdata/colors/colors.dart';

class HomeScreenNew extends StatefulWidget {
  @override
  _HomeScreenNewState createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  // -- Tank & Water details
  double tankCapacity = 1000.0;       // in liters (for percentage calc)
  double fillableVolume = 0.0;        // in liters (for advanced percentage calc if needed)
  double availableWater = 0.0;        // computed from sensor distance
  double todaysWaterUsage = 1500.0;   // placeholder usage

  // -- Firebase DB references
  final DatabaseReference distanceRef =
  FirebaseDatabase.instance.ref("Ultrasonic/distance");
  final DatabaseReference pumpRef =
  FirebaseDatabase.instance.ref("Motor/status");

  // -- No local isPumpOn; we'll read from Firebase directly

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // SCROLLABLE CONTENT
          SingleChildScrollView(
            child: Column(
              children: [
                // TOP BLUE CONTAINER
                Container(
                  height: 0.389 * screenHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blueDark, AppColors.blueDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // Background Image
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 0.21 * screenHeight,
                            margin: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 25,
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/header_background.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        // DropGuard Logo (centered near top)
                        Positioned(
                          top: 0.045 * screenHeight,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/dropguard_logo.png',
                                height: 42,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 0.022 * screenHeight),

                // WATER LEVEL INDICATOR (Sensor Data Stream)
                _buildWaterLevelIndicator(),

                SizedBox(height: 0.022 * screenHeight),

                // WATER PUMP SECTION (Pump Status Stream)
                _buildWaterPumpSection(),

                SizedBox(height: 0.196 * screenHeight),

                // BOTTOM "NAV BAR"
                Container(
                  height: 0.089 * screenHeight,
                  decoration: BoxDecoration(
                    color: AppColors.blueDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, -3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () {
                          // TODO: handle back
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.home),
                        color: Colors.white,
                        onPressed: () {
                          // TODO: handle home
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.menu),
                        color: Colors.white,
                        onPressed: () {
                          // TODO: handle menu
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ****************************************************************
  // WATER LEVEL INDICATOR - STREAMBUILDER FOR SENSOR
  // ****************************************************************
  Widget _buildWaterLevelIndicator() {
    double screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<DatabaseEvent>(
      stream: distanceRef.onValue,
      builder: (context, snapshot) {
        // Default to "0 cm" if no data or error => no flicker
        double sensorDistanceCM = 0.0;

        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          try {
            sensorDistanceCM =
                double.parse(snapshot.data!.snapshot.value.toString());
          } catch (e) {
            debugPrint("Error parsing sensorDistance: $e");
            sensorDistanceCM = 0.0;
          }
        }

        // 1) Calculate available water from sensor
        availableWater = _calculateAvailableWater(sensorDistanceCM);

        // 2) Fill percentage vs fillableVolume
        double fillPercentage = (availableWater / fillableVolume) * 100;
        if (fillPercentage < 0) fillPercentage = 0;
        if (fillPercentage > 100) fillPercentage = 100;

        // 3) Determine fill color
        Color fillColor;
        if (fillPercentage < 20 || fillPercentage > 95) {
          fillColor = AppColors.red;
        } else if (fillPercentage < 50) {
          fillColor = AppColors.orange;
        } else {
          fillColor = AppColors.green;
        }

        // Build UI
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 0.177 * screenHeight,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.green, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left stats
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Water Level Indicator",
                        style: GoogleFonts.sulphurPoint(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 1),
                              blurRadius: 5.2,
                            ),
                          ],
                        ),
                      ),
                      Text("Tank Capacity: ${tankCapacity.toStringAsFixed(0)} L"),
                      Text(
                          "Available Water: ${availableWater.toStringAsFixed(1)} L"),
                      Text(
                        fillPercentage > 95
                            ? "Tank Status: Overflow!"
                            : fillPercentage >= 90
                            ? "Tank Status: Almost Full"
                            : fillPercentage <= 20
                            ? "Tank Status: Extremely Low"
                            : fillPercentage <= 50
                            ? "Tank Status: Low"
                            : "Tank Status: Normal",
                        style: GoogleFonts.sulphurPoint(color: fillColor),
                      ),
                      Text("Today's Water Usage*: $todaysWaterUsage L"),
                      Text(
                        "*Water usage resets at every Midnight",
                        style: GoogleFonts.sulphurPoint(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side: TANK VISUAL
                Flexible(
                  flex: 1,
                  child: _buildTankVisual(fillPercentage, fillColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ****************************************************************
  // STREAMBUILDER FOR PUMP STATUS
  // ****************************************************************
  Widget _buildWaterPumpSection() {
    double screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<DatabaseEvent>(
      stream: pumpRef.onValue,
      builder: (context, snapshot) {
        // Default to OFF if no data or error
        bool pumpOnFromFirebase = false;

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final dynamic pumpVal = snapshot.data!.snapshot.value;
          // Suppose 1 => ON, 0 => OFF
          if (pumpVal == 1) {
            pumpOnFromFirebase = true;
          }
        }

        // Now build the container using that
        return _buildPumpContainer(pumpOnFromFirebase, screenHeight);
      },
    );
  }

  Widget _buildPumpContainer(bool pumpOn, double screenHeight) {
    // If the pump is ON, border color = green, else white
    Color borderColor = pumpOn ? AppColors.green : Colors.white;
    // Switch color
    Color switchActiveColor = pumpOn ? AppColors.green : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 0.107 * screenHeight,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Water Pump",
                  style: GoogleFonts.sulphurPoint(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 1),
                        blurRadius: 5.2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0.013 * screenHeight),
                Text("Estimated Time to fill Water tank: 30 Min"),
              ],
            ),
            // Switch
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 0.65,
                  child: Switch(
                    value: pumpOn,
                    onChanged: (bool value) async {
                      // If toggled => write to Firebase
                      await _togglePump(value);
                    },
                    activeColor: switchActiveColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ***********************************
  // Toggle Pump in Firebase
  // ***********************************
  Future<void> _togglePump(bool turnOn) async {
    try {
      await pumpRef.set(turnOn ? 1 : 0);
      debugPrint("Pump toggled to: ${turnOn ? 'ON' : 'OFF'}");
    } catch (e) {
      debugPrint("Error toggling pump: $e");
    }
  }

  // ***********************************
  // Tank Visualization Widget
  // ***********************************
  Widget _buildTankVisual(double fillPercentage, Color fillColor) {
    const double tankHeight = 100.0;
    const double tankWidth = 80.0;

    double fillHeight = (fillPercentage.clamp(0, 100) / 100) * tankHeight;

    return Container(
      width: tankWidth,
      height: tankHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The filled portion
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: tankWidth,
              height: fillHeight,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
            ),
          ),
          // Overlaid % text with stroke + fill
          Stack(
            alignment: Alignment.center,
            children: [
              // STROKE
              Text(
                "${fillPercentage.toStringAsFixed(0)}%",
                style: GoogleFonts.sulphurPoint(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.5
                    ..color = Colors.white,
                ),
              ),
              // FILL
              Text(
                "${fillPercentage.toStringAsFixed(0)}%",
                style: GoogleFonts.sulphurPoint(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ***********************************
  // Cylinder Volume Calculation
  // ***********************************
  double _calculateAvailableWater(double sensorReadingCM) {
    // Tweak these to match your actual tank
    const double tankHeightCM = 120.0;
    const double slack = 30.0;
    const double diameterCM = 103.0;
    final double radiusCM = diameterCM / 2;
    const double pi = 3.14159265359;

    // For advanced usage, fillableVolume can be set here
    // to reflect the "max" volume if you're ignoring some portion, etc.
    fillableVolume = tankCapacity; // or some custom logic

    double waterHeightCM = tankHeightCM - (sensorReadingCM - slack);
    if (waterHeightCM < 0) waterHeightCM = 0;
    if (waterHeightCM > tankHeightCM) waterHeightCM = tankHeightCM;

    // Cylinder volume in cubic centimeters
    double volumeCC = pi * (radiusCM * radiusCM) * waterHeightCM;

    // Convert to liters
    double volumeLiters = volumeCC / 1000.0;
    return volumeLiters;
  }
}
