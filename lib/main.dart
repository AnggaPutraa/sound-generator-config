import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class MyPainter extends CustomPainter {
  final List<int> oneCycleData;

  MyPainter(this.oneCycleData);

  @override
  void paint(Canvas canvas, Size size) {
    List<Offset> maxPoints = [];

    final t = size.width / (oneCycleData.length - 1);
    for (var i = 0, len = oneCycleData.length; i < len; i++) {
      maxPoints.add(
        Offset(
          t * i,
          size.height / 2 -
              oneCycleData[i].toDouble() / 32767.0 * size.height / 2,
        ),
      );
      i++;
    }

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.polygon, maxPoints, paint);
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    if (oneCycleData != oldDelegate.oneCycleData) {
      return true;
    }
    return false;
  }
}

class _MyAppState extends State<MyApp> {
  bool isPlaying = false;
  double frequency = 4000;
  double balance = 0;
  double volume = 40;
  waveTypes waveType = waveTypes.SINUSOIDAL;
  int sampleRate = 96000;
  List<int>? oneCycleData;

  @override
  void initState() {
    super.initState();
    isPlaying = false;

    SoundGenerator.init(sampleRate);

    SoundGenerator.onIsPlayingChanged.listen((value) {
      // ganti jadi bloc event ini
      setState(() {
        isPlaying = value;
      });
    });

    SoundGenerator.onOneCycleDataHandler.listen((value) {
      setState(() {
        oneCycleData = value;
      });
    });

    SoundGenerator.setAutoUpdateOneCycleSample(true);
    // SoundGenerator.setWaveType(waveTypes.TRIANGLE);
    //Force update for one time
    SoundGenerator.refreshOneCycleData();
    SoundGenerator.setFrequency(500);
  }

  @override
  void dispose() {
    super.dispose();
    SoundGenerator.release();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Coba Sound Generator'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("A Cycle's Snapshot With Real Data"),
              const SizedBox(height: 2),
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 4,
                ),
                child: oneCycleData != null
                    ? CustomPaint(
                        painter: MyPainter(oneCycleData!),
                      )
                    : Container(),
              ),
              const SizedBox(height: 2),
              Text(
                "A Cycle Data Length is ${(sampleRate / frequency).round()} on sample rate $sampleRate",
              ),
              const SizedBox(height: 5),
              const Divider(
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.lightBlueAccent,
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                  onPressed: () {
                    isPlaying ? SoundGenerator.stop() : SoundGenerator.play();
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text("Wave Form"),
              Center(
                child: DropdownButton<waveTypes>(
                  value: waveType,
                  onChanged: (waveTypes? newValue) {
                    setState(() {
                      waveType = newValue!;
                      SoundGenerator.setWaveType(waveType);
                    });
                  },
                  items: waveTypes.values.map(
                    (waveTypes classType) {
                      return DropdownMenuItem<waveTypes>(
                        value: classType,
                        child: Text(classType.toString().split('.').last),
                      );
                    },
                  ).toList(),
                ),
              ),
              const SizedBox(height: 5),
              const Divider(
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              const Text("Frequency"),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text("${frequency.toStringAsFixed(2)} Hz"),
                      ),
                    ),
                    Expanded(
                      flex: 8, // 60%
                      child: Slider(
                        min: 20,
                        max: 10000,
                        value: frequency,
                        onChanged: (value) {
                          setState(
                            () {
                              frequency = value.toDouble();
                              SoundGenerator.setFrequency(frequency);
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text("Balance"),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Center(child: Text(balance.toStringAsFixed(2))),
                    ),
                    Expanded(
                      flex: 8, // 60%
                      child: Slider(
                        min: -1,
                        max: 1,
                        value: balance,
                        onChanged: (value) {
                          setState(
                            () {
                              balance = value.toDouble();
                              SoundGenerator.setBalance(balance);
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text("Volume"),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Center(child: Text(volume.toStringAsFixed(2))),
                    ),
                    Expanded(
                      flex: 8, // 60%
                      child: Slider(
                        min: 0,
                        max: 100,
                        value: volume,
                        onChanged: (value) {
                          print(value);
                          setState(
                            () {
                              volume = value.toDouble();
                              SoundGenerator.setVolume(volume);
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
