/*
 * FLauncher fork
 * Copyright (C) 2021 Étienne Fesser
 * Modifications Copyright (C) 2025 Ephemeral Sapient
 *

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'dart:math';

import 'package:flutter/widgets.dart';

class FLauncherGradient {
  final String uuid;
  final String name;
  final Gradient gradient;

  FLauncherGradient(this.uuid, this.name, this.gradient);
}

mixin FLauncherGradients {
  static final cosmicDream = FLauncherGradient(
    "a1d2f3e4-cosmic-dream",
    "Cosmic Dream",
    SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFF8E2DE2)],
    ),
  );

  static final radiantBurst = FLauncherGradient(
    "b2e3f4a5-radiant-burst",
    "Radiant Burst",
    RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    ),
  );

  static final oceanWhisper = FLauncherGradient(
    "c3f4a5b6-ocean-whisper",
    "Ocean Whisper",
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2BC0E4), Color(0xFFEAECC6)],
    ),
  );

  static final spectrumSplash = FLauncherGradient(
    "d4a5b6c7-spectrum-splash",
    "Spectrum Splash",
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF00F260), Color(0xFF0575E6), Color(0xFF021B79)],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  static final goldenSundrop = FLauncherGradient(
    "e5b6c7d8-golden-sundrop",
    "Golden Sundrop",
    RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [Color(0xFFFFD194), Color(0xFFFF4E50)],
    ),
  );

  static final midnightAurora = FLauncherGradient(
    "f6c7d8e9-midnight-aurora",
    "Midnight Aurora",
    SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: 2 * pi,
      colors: [Color(0xFF232526), Color(0xFF414345), Color(0xFF232526)],
    ),
  );

  static final urbanNight = FLauncherGradient(
    "g7d8e9f0-urban-night",
    "Urban Night",
    LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFF373B44), Color(0xFF4286F4)],
    ),
  );

  /// A wide linear gradient intended for large displays,
  /// blending sunrise colors smoothly left to right.
  static final horizonGlow = FLauncherGradient(
    "h1r2i3z4-horizon-glow",
    "Horizon Glow",
    LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFFFF5C33), // Vivid Orange
        Color(0xFFFFC371), // Lighter Orange
        Color(0xFFFEF9D7), // Pale Yellow
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  /// A large radial gradient that creates a sense of depth in the center.
  static final emeraldSky = FLauncherGradient(
    "e1m2e3r4-emerald-sky",
    "Emerald Sky",
    RadialGradient(
      center: Alignment.center,
      radius: 1.5, // Larger radius for big screens
      colors: [
        Color(0xFF00416A), // Darker Blue-Green
        Color(0xFF00F260), // Vibrant Green
      ],
      stops: [0.3, 1.0],
    ),
  );

  /// A wide sweep gradient simulating a slow color shift around the edges.
  static final twilightPulse = FLauncherGradient(
    "t9w8l7g6-twilight-pulse",
    "Twilight Pulse",
    SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: 2 * pi,
      colors: [
        Color(0xFF0B486B), // Deep Blue
        Color(0xFFF56217), // Sunset Orange
        Color(0xFF0B486B), // Deep Blue
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  /// Another linear gradient that covers a broad color range,
  /// suitable for backgrounds spanning wide TV screens.
  static final dreamySunset = FLauncherGradient(
    "d9r8e7a6-dreamy-sunset",
    "Dreamy Sunset",
    LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xFF4E54C8), // Purple
        Color(0xFF8F94FB), // Lighter purple/blue
        Color(0xFFBFE9FF), // Pale sky
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  static List<FLauncherGradient> get all => [
    cosmicDream,
    radiantBurst,
    oceanWhisper,
    spectrumSplash,
    goldenSundrop,
    midnightAurora,
    urbanNight,
    horizonGlow,
    emeraldSky,
    twilightPulse,
    dreamySunset,
  ];
}
