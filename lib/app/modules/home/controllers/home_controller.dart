import 'dart:isolate';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  void computeHeavyTask() {
    _heavyTask(HeavyTaskExecutionType.withoutAnyIsolates);
  }

  Future<void> computeHeavyTaskWithIsolatesRunMethod() async {
    await Isolate.run(
      () {
        _heavyTask(HeavyTaskExecutionType.withIsolatesRunMethod);
      },
    );
  }

  Future<void> computeHeavyTaskWithIsolatesSpawnMethod() async {
    final port = ReceivePort();
    await Isolate.spawn<SendPort>(
      (sendPort) {
        _heavyTask(
          HeavyTaskExecutionType.withIsolatesSpawnMethod,
          sendPort: sendPort,
        );
      },
      port.sendPort,
    );

    port.listen(
      (message) {
        debugPrint('How heavy task executed ---> $message');
      },
    );
  }

  void _heavyTask(HeavyTaskExecutionType executionType, {SendPort? sendPort}) {
    for (int i = 0; i < 10000000000; i++) {}
    executionType == HeavyTaskExecutionType.withIsolatesRunMethod
        ? debugPrint('Heavy task completed with isolates run method.')
        : executionType == HeavyTaskExecutionType.withIsolatesSpawnMethod
            ? debugPrint('Heavy task completed with isolates spawn method.')
            : debugPrint('Heavy task completed without any isolates.');

    if (sendPort != null) {
      sendPort.send('Heavy task completed with isolates spawn method.');
    }
  }
}

enum HeavyTaskExecutionType {
  withoutAnyIsolates,
  withIsolatesRunMethod,
  withIsolatesSpawnMethod,
}
