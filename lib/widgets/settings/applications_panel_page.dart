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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: GlassyPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: TabBar(
                dividerColor: Colors.transparent,
                enableFeedback: true,
                isScrollable: true,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.lightBlue.withOpacity(0.3),
                ),
                indicatorColor: Colors.lightBlue,
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
              ),
            ),
            // const SizedBox(height: 8),
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

class GlassyAppCard extends StatelessWidget {
  final App application;
  const GlassyAppCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: false,
      onFocusChange: (_) {},
      child: Card(
        color:
            Focus.of(context).hasFocus
                ? Colors.lightBlue.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap:
              () => showDialog(
                context: context,
                builder:
                    (_) => ApplicationInfoPanel(
                      category: null,
                      application: application,
                    ),
              ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Banner or icon
                if (application.banner != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      application.banner!,
                      width: 80,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (application.icon != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: MemoryImage(application.icon!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                // App name, version, size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'v${application.version} - ${application.sizeMb ?? "?"}MB',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Info icon
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white70),
                  splashRadius: 24,
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder:
                            (_) => ApplicationInfoPanel(
                              category: null,
                              application: application,
                            ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
