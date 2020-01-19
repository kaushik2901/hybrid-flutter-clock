import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ClockPainter extends StatelessWidget {
  final currentTime;
  final double secondAngle;
  final double minuteAngle;
  final double hourAngle;
  final Color secondColor;
  final Color minutecolor;
  final Color hourColor;
  final bool is24Hour;

  const ClockPainter({
    Key key,
    this.secondAngle,
    this.minuteAngle,
    this.hourAngle,
    this.secondColor,
    this.minutecolor,
    this.hourColor,
    this.currentTime,
    this.is24Hour,
  }) : super(key: key);

  String getFormatedDate(DateTime currentTime) {
    int day = currentTime.day;
    const stDays = [1, 21, 31];
    const ndDays = [2, 22];
    const rdDays = [3, 23];

    String postfix;

    if (stDays.contains(day)) {
      postfix = "st";
    } else if (ndDays.contains(day)) {
      postfix = "nd";
    } else if (rdDays.contains(day)) {
      postfix = "rd";
    } else {
      postfix = "th";
    }

    return numWithZeroPrefix(day) +
        postfix +
        " " +
        getMonth(currentTime.month - 1);
  }

  String getFormatedHour(hour) {
    if (!is24Hour)
      return numWithZeroPrefix(
          (hour > 12 && hour < 24) ? hour - 12 : (hour == 0) ? 12 : hour);
    return numWithZeroPrefix(hour);
  }

  String numWithZeroPrefix(int i) => i < 10 ? "0" + i.toString() : i.toString();
  String formatedTime(DateTime time) =>
      getFormatedHour(time.hour) + ":" + numWithZeroPrefix(time.minute);
  String getMonth(int i) => i <= 12 && i >= 0
      ? [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "Auguest",
          "September",
          "October",
          "November",
          "December"
        ][i]
      : "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.55 * 0.1;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: CustomPaint(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                formatedTime(currentTime),
                style: TextStyle(fontSize: padding),
              ),
              Text(
                is24Hour ? "" : (currentTime.hour >= 12 ? "PM" : "AM"),
                style: TextStyle(fontSize: padding * 0.3),
              ),
              SizedBox(
                height: padding * 0.1,
              ),
              Text(
                getFormatedDate(currentTime),
                style: TextStyle(fontSize: padding * 0.6),
              )
            ],
          ),
        ),
        painter: CustomClockPainter(
          secondAngle: secondAngle,
          minuteAngle: minuteAngle,
          hourAngle: hourAngle,
          secondColor: secondColor,
          minutecolor: minutecolor,
          hourColor: hourColor,
        ),
      ),
    );
  }
}

class CustomClockPainter extends CustomPainter {
  final double secondAngle;
  final double minuteAngle;
  final double hourAngle;
  final Color secondColor;
  final Color minutecolor;
  final Color hourColor;

  CustomClockPainter({
    this.secondColor,
    this.minutecolor,
    this.hourColor,
    this.secondAngle,
    this.minuteAngle,
    this.hourAngle,
  });

  void _drawClockHand(
    Canvas canvas,
    Size size,
    Offset center,
    double distance,
    double angle,
    double arcAngle,
    Paint paint,
  ) {
    canvas.drawArc(new Rect.fromCircle(center: center, radius: distance),
        -pi / 2 + angle + (arcAngle / 2), 2 * pi - arcAngle, false, paint);
  }

  void _drawClockHandPoint(
    Canvas canvas,
    Offset center,
    double distance,
    double angle,
    double arcAngle,
    Paint paint,
  ) {
    Offset tempPoint = Offset.fromDirection(angle - pi / 2, distance);
    Offset centerOffsetPoint =
        Offset(tempPoint.dx + center.dx, tempPoint.dy + center.dy);

    canvas.drawPoints(PointMode.points, [centerOffsetPoint], paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint arcStroke = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    Paint pointStroke = Paint()
      ..color = Colors.white.withAlpha(127)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025;

    double offset = size.width * 0.08;
    Offset center = Offset(size.width / 2, size.height / 2);

    double secondArcRadius = size.width / 2;
    double secondAngleRadians = 2 * pi * (secondAngle / 360);
    double secondArcAngle = 2 * pi * 18 / 360;

    double minuteArcRadius = size.width / 2 - offset;
    double minuteAngleRadians = 2 * pi * (minuteAngle / 360);
    double minuteArcAngle = secondArcAngle * secondArcRadius / minuteArcRadius;

    double hourArcRadius = size.width / 2 - 2 * offset;
    double hourAngleRadians = 2 * pi * (hourAngle / 360);
    double hourArcAngle = secondArcAngle * secondArcRadius / hourArcRadius;

    _drawClockHand(canvas, size, center, secondArcRadius, secondAngleRadians,
        secondArcAngle, arcStroke..color = secondColor);
    _drawClockHandPoint(canvas, center, secondArcRadius, secondAngleRadians,
        secondArcAngle, pointStroke..color = secondColor);

    _drawClockHand(canvas, size, center, minuteArcRadius, minuteAngleRadians,
        minuteArcAngle, arcStroke..color = minutecolor);
    _drawClockHandPoint(canvas, center, minuteArcRadius, minuteAngleRadians,
        minuteArcAngle, pointStroke..color = minutecolor);

    _drawClockHand(canvas, size, center, hourArcRadius, hourAngleRadians,
        hourArcAngle, arcStroke..color = hourColor);
    _drawClockHandPoint(canvas, center, hourArcRadius, hourAngleRadians,
        hourArcAngle, pointStroke..color = hourColor);

    // For debugging
    // _drawDebugLines(canvas, size);
    // _drawDebugPoints(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Paint refresh rate must be as same as frame rate so we are skipping the calculation.
  }

  void _drawDebugLines(Canvas canvas, Size size) {
    Path path = new Path();
    path.moveTo(size.width / 2, -80);
    path.lineTo(size.width / 2, size.height + 60);
    path.close();

    canvas.drawPath(
      path,
      new Paint()
        ..color = Colors.cyan
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    path = new Path();
    path.moveTo(-80, size.height / 2);
    path.lineTo(size.width + 80, size.height / 2);
    path.close();

    canvas.drawPath(
      path,
      new Paint()
        ..color = Colors.cyan
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawDebugPoints(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.cyan
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;

    canvas.drawPoints(
        PointMode.points, [Offset(size.width / 2, size.height / 2)], paint);
    canvas.drawPoints(PointMode.points, [Offset(0, 0)], paint);
    canvas.drawPoints(
        PointMode.points, [Offset(size.width, size.height)], paint);
    canvas.drawPoints(PointMode.points, [Offset(0, size.height)], paint);
    canvas.drawPoints(PointMode.points, [Offset(size.width, 0)], paint);
  }
}
