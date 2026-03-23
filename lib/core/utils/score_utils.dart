// Utility helpers for formatting trust scores and selecting score colors.
import 'package:flutter/material.dart';

class ScoreUtils {
  static Color trustColor(double score) {
    if (score >= 80) return const Color(0xFF159A4C);
    if (score >= 50) return const Color(0xFFE1A500);
    return const Color(0xFFD03B3B);
  }

  static String trustLabel(double score) {
    if (score >= 80) return 'Highly Trusted';
    if (score >= 50) return 'Moderate';
    return 'Low Trust';
  }
}
