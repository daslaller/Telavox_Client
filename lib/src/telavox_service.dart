import 'dart:async';
import 'dart:developer';
import 'package:telavox_client/telavox_client.dart';

class TelavoxMonitor {
  late Timer? _timer;
  final _eventController =
      StreamController<Map<TelavoxLineStatus, dynamic>>.broadcast();
  final Duration exemptionDuration, pollingInterval;
  final TelavoxClient client;

 Stream<Map<TelavoxLineStatus, dynamic>> get events => _eventController.stream;
 bool get isRunning =>
      !(_timer == null || !_timer!.isActive); 
      
  TelavoxMonitor({
    this.exemptionDuration = const Duration(minutes: 5),
    this.pollingInterval = const Duration(seconds: 10),
    required this.client,
  });

  void startMonitoring() {
    log(name: 'TelavoxMonitor', 'TelavoxMonitor started');
    if (isRunning) stopMonitoring();
    _timer = Timer.periodic(
      pollingInterval,
      (_) => onPoll(),
    ); // Initialize timer
  }

  void stopMonitoring() {
    log(name: 'TelavoxMonitor', 'TelavoxMonitor stopped');
    _timer?.cancel();
  }

  void onPoll() {
    log(name: 'TelavoxMonitor', 'TelavoxMonitor polled');
    _eventController.add({});
  }

  void dispose() {
    _eventController.close();
  }
}