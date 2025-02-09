/*
 * FLauncher fork
 * Copyright (C) 2021 Étienne Fesser
 * Modifications Copyright (C) 2025 Ephemeral Sapient
 *

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WallpaperPanelPage extends StatelessWidget {
  static const String routeName = "wallpaper_panel";

  const WallpaperPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TVButton(
            label: "Pick Custom Wallpaper",
            icon: Icons.image_outlined,
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
          const SizedBox(height: 32),
          Selector<SettingsService, String?>(
            selector: (_, settingsService) => settingsService.unsplashAuthor,
            builder: (context, json, _) {
              if (json != null) {
                final authorInfo = jsonDecode(json);
                return TVButton(
                  label: "Photo by ${authorInfo["username"]} on Unsplash",
                  icon: Icons.photo,
                  onPressed:
                      () => Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder:
                              (context) => WebViewWidget(
                                controller:
                                    WebViewController()..loadRequest(
                                      Uri.parse(authorInfo["link"]),
                                    ),
                              ),
                        ),
                      ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}

class TVButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const TVButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  _TVButtonState createState() => _TVButtonState();
}

class _TVButtonState extends State<TVButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        _isFocused
            ? Colors.lightBlueAccent.withOpacity(0.6)
            : Colors.lightBlueAccent.withOpacity(0.3);

    return FocusableActionDetector(
      autofocus: false,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 32, color: Colors.white),
                  const SizedBox(width: 16),
                  Text(
                    widget.label,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
