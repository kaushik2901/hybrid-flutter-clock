import 'dart:async';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:kaushik_hybrid_clock/ClockPainter.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

final radiansPerSecond = radians(360 / 60);
final radiansPerHour = radians(360 / 12);

class HybridClock extends StatefulWidget {
  const HybridClock(this.model);
  final ClockModel model;

  @override
  _HybridClockState createState() => _HybridClockState();
}

class _HybridClockState extends State<HybridClock> {
  DateTime _currentTime = DateTime.now();
  String _temperature = '';
  String _weather = '';
  String _location = '';
  double secondAngle = 0;
  double minuteAngle = 0;
  double hourAngle = 0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(HybridClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _weather = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
      secondAngle =
          _currentTime.second * 6.0 + _currentTime.millisecond * (6 / 1000);
      minuteAngle = _currentTime.minute * 6.0 + (secondAngle / 60);
      hourAngle = (_currentTime.hour == 0
                  ? 12
                  : (_currentTime.hour > 12
                      ? _currentTime.hour - 12
                      : _currentTime.hour)) *
              30.0 +
          (_currentTime.minute * 0.5) +
          (_currentTime.second / 120);
      _timer = Timer(
        // Duration(seconds: 1) - Duration(milliseconds: _currentTime.millisecond),
        Duration(milliseconds: 5),
        _updateTime,
      );
    });
  }

  String capitalizeWord(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: Color(0xFFF04393),
            highlightColor: Color(0xFF0191B6),
            accentColor: Color(0xFFFF7B17),
            backgroundColor: Color(0xFFFFFFFF),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFF04393),
            highlightColor: Color(0xFFFBC34A),
            accentColor: Color(0xFFE8A39C),
            backgroundColor: Color(0xFF000000),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Hybrid clock, Current time is $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Row(
          children: [
            SizedBox(
                width: size.width * 0.55,
                height: size.height,
                child: ClockPainter(
                  currentTime: _currentTime,
                  hourAngle: hourAngle,
                  minuteAngle: minuteAngle,
                  secondAngle: secondAngle,
                  secondColor: customTheme.primaryColor,
                  minutecolor: customTheme.highlightColor,
                  hourColor: customTheme.accentColor,
                  is24Hour: widget.model.is24HourFormat,
                )),
            Expanded(
              child: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    capitalizeWord(_weather),
                    style: TextStyle(
                      fontSize: size.width * 0.4 * 0.1,
                    ),
                  ),
                  SizedBox(
                    height: size.width * 0.4 * 0.01,
                  ),
                  Text(
                    _temperature,
                    style: TextStyle(fontSize: size.width * 0.4 * 0.225),
                  ),
                  SizedBox(
                    height: size.width * 0.4 * 0.01,
                  ),
                  Text(
                    _location,
                    style: TextStyle(fontSize: size.width * 0.4 * 0.08),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }
}
