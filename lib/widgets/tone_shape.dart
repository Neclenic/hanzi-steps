import 'package:flutter/material.dart';

import '../data/course.dart';

/// Draws the pitch "shape" of a tone: a line from left to right,
/// higher on the chart means a higher voice.
class ToneShape extends StatelessWidget {
  final int tone;
  final double size;
  final Color color;
  final bool showGrid;
  const ToneShape({super.key, required this.tone, this.size = 40, required this.color, this.showGrid = false});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size * 1.3, size),
        painter: _TonePainter(tones[tone - 1].contour, color, showGrid,
            Theme.of(context).colorScheme.outlineVariant),
      );
}

class _TonePainter extends CustomPainter {
  final List<double> contour;
  final Color color;
  final bool grid;
  final Color gridColor;
  _TonePainter(this.contour, this.color, this.grid, this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    final pad = size.height * 0.12;
    double y(double level) => pad + (5 - level) / 4 * (size.height - 2 * pad);

    if (grid) {
      final g = Paint()
        ..color = gridColor
        ..strokeWidth = 1;
      for (var lvl = 1; lvl <= 5; lvl++) {
        canvas.drawLine(Offset(0, y(lvl.toDouble())), Offset(size.width, y(lvl.toDouble())), g);
      }
    }

    final pts = <Offset>[
      for (var i = 0; i < contour.length; i++)
        Offset(pad + i / (contour.length - 1) * (size.width - 2 * pad), y(contour[i])),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 3) {
      // Smooth dip for the third tone.
      final c = Offset(pts[1].dx, pts[1].dy + (size.height * 0.12));
      path.quadraticBezierTo(c.dx, c.dy, pts[2].dx, pts[2].dy);
    } else {
      path.lineTo(pts.last.dx, pts.last.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = size.height * 0.1);
  }

  @override
  bool shouldRepaint(covariant _TonePainter old) => old.contour != contour || old.color != color;
}
