import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TempC extends StatefulWidget {
  final CollectionReference mqttData =
      FirebaseFirestore.instance.collection('mqtt_data');

  TempC({super.key});

  @override
  _TempCState createState() => _TempCState();
}

class _TempCState extends State<TempC> {
  double lastTempValue = 0.0;
  double pressureValue = 0.0;
  String targetId = "Simulation Examples.Functions.Random1";
  String pressureTargetId = "Simulation Examples.Functions.Random3";
  String maintenanceTargetId = "Channel1test.Device22.dv2input";
  String downtimeTargetId = "Channel1test.Device22.dv2input";

  // Downtime tracking variables
  DateTime? _downtimeStart;
  Duration _currentDowntime = Duration.zero;
  bool _isInDowntime = false;

  // Maintenance alert variables
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _lastMaintenanceState = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showMaintenanceAlert(String message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'maintenance_channel',
      'Maintenance Alerts',
      channelDescription: 'Alerts for system maintenance',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      color: Colors.red,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await notificationsPlugin.show(
      0,
      'Alerte de Maintenance',
      message,
      notificationDetails,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours h ${twoDigits(minutes)} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: widget.mqttData
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error retrieving data');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No data available');
              }

              final document = snapshot.data!.docs.first;
              final data = document.data() as Map<String, dynamic>;

              if (!data.containsKey('values')) {
                return const Text('Temperature data not found');
              }

              // Temperature data
              var tempEntry = (data['values'] as List).firstWhere(
                (entry) => entry['id'] == targetId,
                orElse: () => null,
              );

              if (tempEntry != null && tempEntry.containsKey('v')) {
                lastTempValue =
                    double.tryParse(tempEntry['v'].toString()) ?? lastTempValue;
              }

              // Pressure data
              var pressureEntry = (data['values'] as List).firstWhere(
                (entry) => entry['id'] == pressureTargetId,
                orElse: () => null,
              );

              if (pressureEntry != null && pressureEntry.containsKey('v')) {
                pressureValue =
                    double.tryParse(pressureEntry['v'].toString()) ?? 0.0;
              }

              // Downtime tracking (using Simulation Examples.Functions.User3)
              var downtimeEntry = (data['values'] as List).firstWhere(
                (entry) => entry['id'] == downtimeTargetId,
                orElse: () => null,
              );

              if (downtimeEntry != null && downtimeEntry.containsKey('v')) {
                bool currentDowntimeState = downtimeEntry['v'] == true;

                if (currentDowntimeState && !_isInDowntime) {
                  // Downtime started
                  _downtimeStart = DateTime.now();
                  _isInDowntime = true;
                } else if (!currentDowntimeState && _isInDowntime) {
                  // Downtime ended
                  _isInDowntime = false;
                  _currentDowntime = Duration.zero;
                }

                // Update current downtime duration if still in downtime
                if (_isInDowntime && _downtimeStart != null) {
                  _currentDowntime = DateTime.now().difference(_downtimeStart!);
                }
              }

              // Maintenance alerts (using Channel1test.Device22.dv2input)
              var maintenanceEntry = (data['values'] as List).firstWhere(
                (entry) => entry['id'] == maintenanceTargetId,
                orElse: () => null,
              );

              if (maintenanceEntry != null &&
                  maintenanceEntry.containsKey('v')) {
                bool currentMaintenanceState = maintenanceEntry['v'] == true;

                if (currentMaintenanceState && !_lastMaintenanceState) {
                  _showMaintenanceAlert(
                      'Maintenance required - System alert detected');
                }
                _lastMaintenanceState = currentMaintenanceState;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Temperature Gauge
                  SfRadialGauge(
                    axes: [
                      RadialAxis(
                        maximum: 300,
                        interval: 40,
                        ticksPosition: ElementsPosition.outside,
                        labelsPosition: ElementsPosition.outside,
                        minorTicksPerInterval: 5,
                        axisLineStyle: const AxisLineStyle(
                          thicknessUnit: GaugeSizeUnit.factor,
                          thickness: 0.1,
                        ),
                        axisLabelStyle: const GaugeTextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        radiusFactor: 0.5,
                        majorTickStyle: const MajorTickStyle(
                            length: 0.1,
                            thickness: 2,
                            lengthUnit: GaugeSizeUnit.factor),
                        minorTickStyle: const MinorTickStyle(
                            length: 0.05,
                            thickness: 1.5,
                            lengthUnit: GaugeSizeUnit.factor),
                        ranges: [
                          GaugeRange(
                              startValue: 0,
                              endValue: 300,
                              startWidth: 0.1,
                              sizeUnit: GaugeSizeUnit.factor,
                              endWidth: 0.1,
                              gradient: const SweepGradient(stops: <double>[
                                0.1,
                                0.5,
                                0.9,
                              ], colors: <Color>[
                                Colors.red,
                                Colors.green,
                                Colors.red,
                              ]))
                        ],
                        pointers: [
                          NeedlePointer(
                            value: lastTempValue,
                            needleColor: Colors.black,
                            tailStyle: const TailStyle(
                                length: 0.2,
                                width: 6,
                                color: Colors.black,
                                lengthUnit: GaugeSizeUnit.factor),
                            needleLength: 0.6,
                            needleStartWidth: 1,
                            needleEndWidth: 6,
                            knobStyle: const KnobStyle(
                                knobRadius: 0.07,
                                color: Colors.white,
                                borderWidth: 0.05,
                                borderColor: Colors.black),
                            lengthUnit: GaugeSizeUnit.factor,
                          )
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Text(
                              'Température du moteur (${lastTempValue.toStringAsFixed(1)}°C):',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            positionFactor: 1,
                            angle: 90,
                          )
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pressure Gauge
                  SfRadialGauge(
                    axes: [
                      RadialAxis(
                        maximum: 1000,
                        interval: 100,
                        ticksPosition: ElementsPosition.outside,
                        labelsPosition: ElementsPosition.outside,
                        minorTicksPerInterval: 5,
                        axisLineStyle: const AxisLineStyle(
                          thicknessUnit: GaugeSizeUnit.factor,
                          thickness: 0.1,
                        ),
                        axisLabelStyle: const GaugeTextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        radiusFactor: 0.5,
                        majorTickStyle: const MajorTickStyle(
                            length: 0.1,
                            thickness: 2,
                            lengthUnit: GaugeSizeUnit.factor),
                        minorTickStyle: const MinorTickStyle(
                            length: 0.05,
                            thickness: 1.5,
                            lengthUnit: GaugeSizeUnit.factor),
                        ranges: [
                          GaugeRange(
                              startValue: 0,
                              endValue: 1000,
                              startWidth: 0.1,
                              sizeUnit: GaugeSizeUnit.factor,
                              endWidth: 0.1,
                              gradient: const SweepGradient(stops: <double>[
                                0.1,
                                0.5,
                                0.9,
                              ], colors: <Color>[
                                Colors.blue,
                                Colors.green,
                                Colors.blue,
                              ]))
                        ],
                        pointers: [
                          NeedlePointer(
                            value: -pressureValue,
                            needleColor: Colors.black,
                            tailStyle: const TailStyle(
                                length: 0.2,
                                width: 6,
                                color: Colors.black,
                                lengthUnit: GaugeSizeUnit.factor),
                            needleLength: 0.6,
                            needleStartWidth: 1,
                            needleEndWidth: 6,
                            knobStyle: const KnobStyle(
                                knobRadius: 0.07,
                                color: Colors.white,
                                borderWidth: 0.05,
                                borderColor: Colors.black),
                            lengthUnit: GaugeSizeUnit.factor,
                          )
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Text(
                              'Pression pneumatique (${(-pressureValue).toStringAsFixed(1)} bar):',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            positionFactor: 1,
                            angle: 90,
                          )
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Downtime Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isInDowntime ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isInDowntime
                              ? 'Machine à l\'arrêt'
                              : 'Machine en marche',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isInDowntime)
                          Text(
                            'Temps d\'arrêt: ${_formatDuration(_currentDowntime)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Maintenance Status (from Channel1test.Device22.dv2input)
                  if (_lastMaintenanceState)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      color: Colors.orange,
                      child: const Text(
                        'Maintenance en cours',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
