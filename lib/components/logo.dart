import 'package:flutter/material.dart';
import 'package:sms_mirror/config/theme.dart';

const logoNameHeroTag = 'AppNameLogo';
const logoImageHeroTag = 'AppImageLogo';

TextSpan nameLogo([int? variant]) {
  final variants = [
    (fontSize: 32.0, payWeight: FontWeight.w600, wiWeight: FontWeight.bold),
    (fontSize: 24.0, payWeight: FontWeight.w600, wiWeight: FontWeight.bold),
  ];
  final v = variants[variant ?? 0];
  return TextSpan(
    text: 'SMS',
    children: [
      TextSpan(
        text: 'Mirror',
        style: TextStyle(fontWeight: v.payWeight, color: Colors.black87),
      ),
    ],
    style: TextStyle(
      fontSize: v.fontSize,
      fontWeight: v.wiWeight,
      letterSpacing: 1.2,
      height: 1,
      color: AppTheme.orange,
    ),
  );
}
