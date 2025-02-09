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

import 'dart:ui'; // For BackdropFilter if you want a glassy overlay

import 'package:flauncher/providers/wallpaper_service.dart'
    show NoFileExplorerException, WallpaperService;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WallpaperPanelPage extends StatelessWidget {
  static const String routeName = "wallpaper_panel";

  const WallpaperPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example layout with a frosted glass background and a grid of option cards
    return Stack(
      children: [
        // Optional: If you want a blurry/frosted effect behind the GridView
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),

        Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Adjust column count for your layout
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                padding: const EdgeInsets.all(30),
                childAspectRatio: 16 / 9, // Wider items for big screens
                children: [
                  WallpaperOptionCard(
                    label: "Device Photo",
                    icon: Icons.photo_library_outlined,
                    onPressed: () async {
                      try {
                        await context.read<WallpaperService>().pickWallpaper();
                      } on NoFileExplorerException {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 8),
                            content: Row(
                              children: const [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Please install a file explorer in order to pick an image.",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  WallpaperOptionCard(
                    label: "Web Photo",
                    icon: Icons.cloud_download_outlined,
                    onPressed: _mockAction,
                  ),
                  WallpaperOptionCard(
                    label: "Device Video",
                    icon: Icons.videocam_outlined,
                    onPressed: _mockAction,
                  ),
                  WallpaperOptionCard(
                    label: "Web Video",
                    icon: Icons.videocam_rounded,
                    onPressed: _mockAction,
                  ),
                  WallpaperOptionCard(
                    label: "Slideshow",
                    icon: Icons.slideshow_outlined,
                    onPressed: _mockAction,
                  ),
                  WallpaperOptionCard(
                    label: "Random Image",
                    icon: Icons.shuffle_rounded,
                    onPressed: _mockAction,
                  ),
                  WallpaperOptionCard(
                    label: "Visualizer",
                    icon: Icons.graphic_eq_outlined,
                    onPressed: _mockAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Just a placeholder for demonstration, remove or replace with real logic
  static void _mockAction() {}
}

/// Redesigned “card” with a new animation style:
/// - No rotation
/// - Scale + color glow on focus
/// - Icon & label fade in more strongly on focus
class WallpaperOptionCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const WallpaperOptionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<WallpaperOptionCard> createState() => _WallpaperOptionCardState();
}

class _WallpaperOptionCardState extends State<WallpaperOptionCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: false,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: _buildAnimatedCard(),
    );
  }

  Widget _buildAnimatedCard() {
    // We’ll drive the UI with a TweenAnimationBuilder from 0.0 to 1.0
    // where 0 = unfocused, 1 = fully focused
    final targetValue = _isFocused ? 1.0 : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: targetValue, end: targetValue),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        // animValue goes from 0..1. We use it to derive scale, color intensity, etc.
        final scale = 1.0 + (animValue * 0.08); // from 1.0 to 1.08
        final glowOpacity = animValue * 0.5; // from 0.0 to 0.5
        final containerColor =
            Color.lerp(
              Colors.lightBlueAccent.withOpacity(0.15),
              Colors.lightBlueAccent.withOpacity(0),
              animValue,
            )!;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              // Use a simple box color or a gradient
              color: containerColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlueAccent.withOpacity(glowOpacity),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: widget.onPressed,
              child: _buildCardContents(animValue),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContents(double focusValue) {
    // We can also fade the icon & label based on focusValue
    final double iconOpacity = 0.5 + (focusValue * 0.5); // from 0.5 -> 1.0
    final double textOpacity = 0.7 + (focusValue * 0.3); // from 0.7 -> 1.0
    final double textSize = 18 + (focusValue * 4); // from 18 -> 22

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: iconOpacity,
            duration: const Duration(milliseconds: 150),
            child: Icon(widget.icon, size: 42, color: Colors.white),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            opacity: textOpacity,
            duration: const Duration(milliseconds: 150),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
