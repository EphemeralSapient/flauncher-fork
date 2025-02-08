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
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WallpaperPanelPage extends StatelessWidget {
  static const String routeName = "wallpaper_panel";

  const WallpaperPanelPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text("Wallpaper", style: Theme.of(context).textTheme.titleLarge),
      Divider(),
      TextButton(
        child: Row(
          children: [
            Icon(Icons.insert_drive_file_outlined),
            Container(width: 8),
            Text("Custom", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        onPressed: () async {
          try {
            await context.read<WallpaperService>().pickWallpaper();
          } on NoFileExplorerException {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 8),
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Please install a file explorer in order to pick an image.",
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      Spacer(),
      Selector<SettingsService, String?>(
        selector: (_, settingsService) => settingsService.unsplashAuthor,
        builder: (context, json, _) {
          if (json != null) {
            final authorInfo = jsonDecode(json);
            return TextButton(
              onPressed:
                  () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder:
                          (context) => WebViewWidget(
                            controller:
                                WebViewController()
                                  ..loadRequest(Uri.parse(authorInfo["link"])),
                          ),
                    ),
                  ),
              child: Text(
                "Photo by ${authorInfo["username"]} on Unsplash",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    ],
  );
}
