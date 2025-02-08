// FILE: flauncher_about_dialog.dart
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

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FLauncherAboutDialog extends StatefulWidget {
  final PackageInfo packageInfo;

  const FLauncherAboutDialog({super.key, required this.packageInfo});

  @override
  State<FLauncherAboutDialog> createState() => _FLauncherAboutDialogState();
}

class _FLauncherAboutDialogState extends State<FLauncherAboutDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _iconRotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _iconRotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium!;
    final underlined = textStyle.copyWith(decoration: TextDecoration.underline);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AboutDialog(
          applicationName: widget.packageInfo.appName,
          applicationVersion:
              "${widget.packageInfo.version} (${widget.packageInfo.buildNumber})",
          applicationIcon: RotationTransition(
            turns: _iconRotationAnimation,
            child: Image.asset("assets/logo.png", height: 72),
          ),
          applicationLegalese:
              "© 2021 Étienne Fesser\nModifications © 2025 Ephemeral Sapient",
          children: [
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: textStyle,
                children: [
                  const TextSpan(
                    text:
                        "FLauncher is an open-source alternative launcher for Android TV.\n"
                        "Source code available at ",
                  ),
                  TextSpan(
                    text: "https://github.com/EphemeralSapient/flauncher-fork",
                    style: underlined,
                  ),
                  const TextSpan(text: ".\n\n"),
                  const TextSpan(text: "Logo by Katie "),
                  TextSpan(text: "@fureturoe", style: underlined),
                  const TextSpan(text: ", design by "),
                  TextSpan(text: "@FXCostanzo", style: underlined),
                  const TextSpan(text: ".\n\n"),
                  const TextSpan(
                    text: "Forked and enhanced by Ephemeral Sapient.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
