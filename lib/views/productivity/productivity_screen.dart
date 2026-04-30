import 'dart:async';
import 'package:flutter/material.dart';
import 'package:postgram/services/firestore_service.dart';
import 'package:postgram/utils/theme.dart';
import 'package:postgram/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ProductivityScreen extends StatefulWidget {
  const ProductivityScreen({super.key});

  @override
  State<ProductivityScreen> createState() => _ProductivityScreenState();
}

class _ProductivityScreenState extends State<ProductivityScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isFocusMode = false;
  final TextEditingController _hoursController = TextEditingController();

  void startFocusMode(int minutes) {
    setState(() {
      _isFocusMode = true;
      _secondsRemaining = minutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        stopFocusMode();
      }
    });
  }

  void stopFocusMode() {
    _timer?.cancel();
    setState(() {
      _isFocusMode = false;
      _secondsRemaining = 0;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void logStudyHours(String uid) async {
    if (_hoursController.text.isNotEmpty) {
      double hours = double.parse(_hoursController.text);
      await FirestoreService().updateStudyHours(uid, hours);
      _hoursController.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Study hours logged! + Points earned')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserViewModel>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Study Chart Section
            const Text(
              'Weekly Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Text(days[value.toInt()], style: const TextStyle(color: Colors.grey));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    makeGroupData(0, 5),
                    makeGroupData(1, 7),
                    makeGroupData(2, 3),
                    makeGroupData(3, 8),
                    makeGroupData(4, user.studyHours % 10), // Example data
                    makeGroupData(5, 2),
                    makeGroupData(6, 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Log Hours Section
            const Text(
              'Log Study Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 2.5',
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => logStudyHours(user.uid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Log'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Focus Mode Section
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.8), Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.timer_rounded, size: 48, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text(
                      'Focus Mode',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _isFocusMode ? 'Time to grind!' : 'Block distractions and earn bonus points',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      formatTime(_secondsRemaining),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 20),
                    _isFocusMode
                        ? ElevatedButton(
                            onPressed: stopFocusMode,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            child: const Text('Quit Session'),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => startFocusMode(25),
                                style: ElevatedButton.styleFrom(foregroundColor: accentColor),
                                child: const Text('25 Min'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => startFocusMode(50),
                                style: ElevatedButton.styleFrom(foregroundColor: accentColor),
                                child: const Text('50 Min'),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: blueColor,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
