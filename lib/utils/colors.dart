import 'package:flutter/material.dart';

// Meta / Horizon inspired dark palette
const Color backgroundColor = Color(0xFF0E0E0E);
const Color surfaceColor = Color(0xFF1A1A1A);
const Color cardColor = Color(0xFF242424);
const Color dividerColor = Color(0xFF2E2E2E);

// Brand Gradient (Meta Horizon purple → blue)
const Color primaryPurple = Color(0xFF7B2FFF);
const Color primaryBlue = Color(0xFF0866FF);
const Color accentCyan = Color(0xFF00C2FF);

// Text
const Color textPrimary = Color(0xFFFFFFFF);
const Color textSecondary = Color(0xFF9E9E9E);
const Color textHint = Color(0xFF5C5C5C);

// Status
const Color greenOnline = Color(0xFF00D26A);
const Color redError = Color(0xFFFF3B30);
const Color yellowWarning = Color(0xFFFFCC00);

// Gradients
const LinearGradient brandGradient = LinearGradient(
  colors: [primaryPurple, primaryBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient darkGradient = LinearGradient(
  colors: [Color(0xFF1A1A2E), Color(0xFF0E0E0E)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
