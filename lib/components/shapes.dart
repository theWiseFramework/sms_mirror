import 'dart:math' as math;

import 'package:flutter/material.dart';


class HexagonBorder extends ShapeBorder {
  final BorderSide side;

  const HexagonBorder({this.side = BorderSide.none});

  Path _hexPath(Rect rect) {
    final w = rect.width;
    final h = rect.height;

    final dx = w / 2;
    final dy = h / 4;

    return Path()
      // top point
      ..moveTo(rect.left + dx, rect.top)
      // top-right edge
      ..lineTo(rect.right, rect.top + dy)
      // bottom-right edge
      ..lineTo(rect.right, rect.bottom - dy)
      // bottom point
      ..lineTo(rect.left + dx, rect.bottom)
      // bottom-left edge
      ..lineTo(rect.left, rect.bottom - dy)
      // top-left edge
      ..lineTo(rect.left, rect.top + dy)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _hexPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _hexPath(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;

    final paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = side.width;

    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) => HexagonBorder(side: side.scale(t));
}

class HeptagonBorder extends ShapeBorder {
  final BorderSide side;

  const HeptagonBorder({this.side = BorderSide.none});

  Path _heptagonPath(Rect rect) {
    const sides = 7;

    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final radius = math.min(rect.width, rect.height) / 2;

    // Rotate so one edge is flat at the bottom
    // Explanation:
    // - 2π / sides = angle between vertices
    // - offset by half that angle so the bottom is an edge, not a point
    final rotation = math.pi / 2 + math.pi / sides;

    final path = Path();

    for (int i = 0; i < sides; i++) {
      final angle = rotation + (2 * math.pi * i / sides);
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _heptagonPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _heptagonPath(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;

    final paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = side.width;

    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) => HeptagonBorder(side: side.scale(t));
}

class HexagonBorder2 extends ShapeBorder {
  final double sideInsetFactor; // controls how “flat” the left/right sides are
  final BorderSide side;

  const HexagonBorder2({
    this.sideInsetFactor =
        0.25, // 0.25 => nice regular-ish hex for typical aspect ratios
    this.side = BorderSide.none,
  });

  Path _hexPath(Rect rect) {
    final w = rect.width;
    final h = rect.height;
    final inset = (w * sideInsetFactor).clamp(0.0, w / 2);

    return Path()
      ..moveTo(rect.left + inset, rect.top)
      ..lineTo(rect.right - inset, rect.top)
      ..lineTo(rect.right, rect.top + h / 2)
      ..lineTo(rect.right - inset, rect.bottom)
      ..lineTo(rect.left + inset, rect.bottom)
      ..lineTo(rect.left, rect.top + h / 2)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _hexPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    // Deflate by the border width so the inner path sits inside the stroke.
    final inset = side.width;
    return _hexPath(rect.deflate(inset));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;

    final paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = side.width;

    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) =>
      HexagonBorder2(sideInsetFactor: sideInsetFactor, side: side.scale(t));

  @override
  ShapeBorder lerpFrom(ShapeBorder? a, double t) => this;

  @override
  ShapeBorder lerpTo(ShapeBorder? b, double t) => this;
}
