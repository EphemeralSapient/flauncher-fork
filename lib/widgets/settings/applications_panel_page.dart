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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:ui' show ImageFilter;

import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/add_to_category_dialog.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A modern, glassy ApplicationsPanelPage suitable for TV
class ApplicationsPanelPage extends StatefulWidget {
  static const String routeName = "applications_panel";
  const ApplicationsPanelPage({super.key});

  @override
  State<ApplicationsPanelPage> createState() => _ApplicationsPanelPageState();
}

class _ApplicationsPanelPageState extends State<ApplicationsPanelPage> {
  String _title = "TV Applications";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: GlassyPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title and TabBar are padded for a modern look.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Divider(
              color: Colors.white54,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            Material(
              color: Colors.transparent,
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.lightBlueAccent.withOpacity(0.3),
                ),
                indicatorAnimation: TabIndicatorAnimation.elastic,
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
                tabs: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Tab(icon: Icon(Icons.tv), text: "TV Applications"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Tab(
                      icon: Icon(Icons.android),
                      text: "Non-TV Applications",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Tab(
                      icon: Icon(Icons.visibility_off_outlined),
                      text: "Hidden Applications",
                    ),
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        _title = "TV Applications";
                        break;
                      case 1:
                        _title = "Non-TV Applications";
                        break;
                      case 2:
                        _title = "Hidden Applications";
                        break;
                      default:
                        _title = "Applications";
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            // Expanded TabBarView with glassy scroll lists
            Expanded(
              child: TabBarView(
                children: [_TVTab(), _SideloadedTab(), _HiddenTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A glassy container widget with a blurred background effect.
class GlassyPanel extends StatelessWidget {
  final Widget child;
  const GlassyPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: child,
        ),
      ),
    );
  }
}

/// TV Applications tab
class _TVTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Selector<AppsService, List<App>>(
    selector:
        (_, appsService) =>
            appsService.applications
                .where((app) => !app.sideloaded && !app.hidden)
                .toList(),
    builder:
        (context, applications, _) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            return EnsureVisible(
              alignment: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassyAppCard(application: applications[index]),
              ),
            );
          },
        ),
  );
}

/// Sideloaded Applications tab
class _SideloadedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Selector<AppsService, List<App>>(
    selector:
        (_, appsService) =>
            appsService.applications
                .where((app) => app.sideloaded && !app.hidden)
                .toList(),
    builder:
        (context, applications, _) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            return EnsureVisible(
              alignment: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassyAppCard(application: applications[index]),
              ),
            );
          },
        ),
  );
}

/// Hidden Applications tab
class _HiddenTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Selector<AppsService, List<App>>(
    selector:
        (_, appsService) =>
            appsService.applications.where((app) => app.hidden).toList(),
    builder:
        (context, applications, _) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            return EnsureVisible(
              alignment: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassyAppCard(application: applications[index]),
              ),
            );
          },
        ),
  );
}

/// A glassy, remote‑friendly app card.
class GlassyAppCard extends StatelessWidget {
  final App application;
  const GlassyAppCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: false,
      onFocusChange: (focused) {},
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: Focus.of(context).hasFocus ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.read<AppsService>().launchApp(application),
          onLongPress:
              () => showDialog<Category>(
                context: context,
                builder: (_) => AddToCategoryDialog(application),
              ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Icon (with fallback if missing)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                    image:
                        application.icon != null && application.icon!.isNotEmpty
                            ? DecorationImage(
                              image: MemoryImage(application.icon!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Application name
                Expanded(
                  child: Text(
                    application.name,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!application.hidden)
                      IconButton(
                        icon: const Icon(
                          Icons.add_box_outlined,
                          color: Colors.lightBlueAccent,
                        ),
                        splashRadius: 24,
                        onPressed:
                            () => showDialog<Category>(
                              context: context,
                              builder: (_) => AddToCategoryDialog(application),
                            ),
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                      ),
                      splashRadius: 24,
                      onPressed:
                          () => showDialog(
                            context: context,
                            builder:
                                (context) => ApplicationInfoPanel(
                                  category: null,
                                  application: application,
                                ),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
