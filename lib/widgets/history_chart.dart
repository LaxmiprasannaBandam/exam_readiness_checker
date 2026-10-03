import 'package:flutter/material.dart';

import '../models/assessment.dart';
import '../utils/date_helper.dart';

/// A simple line chart drawn with Flutter's CustomPainter.
/// (No chart package needed.)
class HistoryChart extends StatelessWidget {
  const HistoryChart({super.key, required this.records, this.height = 220});

  final List<AssessmentRecord> records;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(
          values: records.map((r) => r.score).toList(),
          labels: records.map((r) => DateHelper.short(r.date)).toList(),
          lineColor: scheme.primary,
          gridColor: scheme.onSurface.withOpacity(0.08),
          textColor: scheme.onSurface.withOpacity(0.55),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize,
      {bool centered = false, FontWeight weight = FontWeight.normal}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centered ? offset.dx - painter.width / 2 : offset.dx;
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0;
    const rightPad = 16.0;
    const topPad = 20.0;
    const bottomPad = 28.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Horizontal grid lines + y-axis labels (0, 25, 50, 75, 100).
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final v in [0, 25, 50, 75, 100]) {
      final y = topPad + chartH * (1 - v / 100);
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
      _drawText(canvas, '$v', Offset(0, y - 6), 10);
    }

    if (values.isEmpty) return;

    // Convert the i-th score into a pixel position.
    Offset pointAt(int i) {
      final x = values.length == 1
          ? leftPad + chartW / 2
          : leftPad + chartW * i / (values.length - 1);
      final clamped = values[i].clamp(0.0, 100.0).toDouble();
      final y = topPad + chartH * (1 - clamped / 100);
      return Offset(x, y);
    }

    final linePath = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      linePath.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    // Soft fill under the line.
    if (values.length > 1) {
      final bottom = topPad + chartH;
      final areaPath = Path.from(linePath)
        ..lineTo(pointAt(values.length - 1).dx, bottom)
        ..lineTo(pointAt(0).dx, bottom)
        ..close();
      canvas.drawPath(
        areaPath,
        Paint()
          ..color = lineColor.withOpacity(0.12)
          ..style = PaintingStyle.fill,
      );
    }

    // The line itself.
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Dots, value labels and x-axis date labels.
    final step = (values.length / 6).ceil(); // avoid crowded labels
    for (var i = 0; i < values.length; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 6, Paint()..color = lineColor);
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);

      if (values.length <= 8) {
        _drawText(canvas, '${values[i].round()}%', Offset(p.dx, p.dy - 20), 11,
            centered: true, weight: FontWeight.w700);
      }
      if (i % step == 0 || i == values.length - 1) {
        _drawText(canvas, labels[i], Offset(p.dx, topPad + chartH + 8), 10,
            centered: true);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
