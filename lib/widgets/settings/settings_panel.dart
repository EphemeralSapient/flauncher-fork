/* (C) 2021 Étienne Fesser
 * Modifications Copyright (C) 2025 Ephemeral Sapient
 *
 * This program is free software: you can redistribute ite and/or modify
 * it under the termsr of the GNU General Public License as published by
 * thev Free Software Foundation, either version 3 of the License, or
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
import 'dart:ui';

import 'package:flauncher/providers/settings_service.dart' show SettingsService;
import 'package:flauncher/widgets/settings/applications_panel_page.dart'
    show ApplicationsPanelPage;
import 'package:flauncher/widgets/settings/categories_panel_page.dart'
    show CategoriesPanelPage;
import 'package:flauncher/widgets/settings/flauncher_about_dialog.dart'
    show FLauncherAboutDialog;
import 'package:flauncher/widgets/settings/gradient_panel_page.dart'
    show GradientPanelPage;
import 'package:flauncher/widgets/settings/wallpaper_panel_page.dart'
    show WallpaperPanelPage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});
  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with TickerProviderStateMixin {
  /// Options: "home", "applications", "categories", "gradient", "wallpaper"
  String _selectedPanel = 'home';
  bool _use24HourTime = false;
  bool _highlightAnimation = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// When “About” is selected, show the about dialog.
  void _showAboutDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();
    showDialog(
      context: context,
      builder: (_) => FLauncherAboutDialog(packageInfo: packageInfo),
    );
  }

  Widget _buildMenuList(double panelWidth, var settingsService) {
    // Define menu button data
    final menuItemsData = [
      {
        'icon': Icons.tv,
        'label': "Applications",
        'panel': 'applications',
        'autofocus': false,
      },
      {'icon': Icons.category, 'label': "Categories", 'panel': 'categories'},
      {'icon': Icons.gradient, 'label': "Gradient", 'panel': 'gradient'},
      {'icon': Icons.wallpaper, 'label': "Wallpaper", 'panel': 'wallpaper'},
    ];

    // Build a list of MenuButton widgets from the data.
    final menuButtons =
        menuItemsData.map((item) {
          return MenuButton(
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            isSelected: _selectedPanel == item['panel'],
            autofocus: item['autofocus'] != null && item['autofocus'] == true,
            onTap: () {
              setState(() {
                _selectedPanel = item['panel'] as String;
              });
            },
          );
        }).toList();

    // Assemble the complete list of items.
    final items = <Widget>[
      const Text(
        "Settings",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 20),
      ...menuButtons,
      MenuButton(
        icon: Icons.info_outline,
        label: "About",
        isSelected: false,
        onTap: _showAboutDialog,
      ),
      const SizedBox(height: 20),
      SwitchTile(
        label: "Use 24-hour time",
        value: settingsService.use24HourTimeFormat,
        onChanged: (val) {
          setState(() {
            _use24HourTime = val;
          });
          // Persist the new setting
          settingsService.setUse24HourTimeFormat(val);
        },
      ),
      SwitchTile(
        label: "Highlight Animation",
        value: settingsService.appHighlightAnimationEnabled,
        onChanged: (val) {
          setState(() {
            _highlightAnimation = val;
          });
          // Persist the new setting
          settingsService.setAppHighlightAnimationEnabled(val);
        },
      ),
    ];

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder:
              (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
          children:
              items
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: e,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Panel occupies about 50% of screen width and 70% of its height.
    final double panelWidth = MediaQuery.of(context).size.width * 0.5;
    final double panelHeight = MediaQuery.of(context).size.height * 0.7;
    final settingsService = Provider.of<SettingsService>(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: panelWidth,
          height: panelHeight,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Row(
                children: [
                  Container(
                    width: panelWidth * 0.60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      border: Border(
                        right: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: _buildMenuList(panelWidth, settingsService),
                    ),
                  ),
                  // Right content area with animated slide/fade/scale transition.
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(0.2, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        );

                        final scaleAnimation = Tween<double>(
                          begin: 0,
                          end: 1,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        );

                        return ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: scaleAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: _buildContentPanel(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Return the appropriate content panel.
  Widget _buildContentPanel() {
    switch (_selectedPanel) {
      case 'home':
        return const ContentPanel(
          key: ValueKey('home'),
          title: "Home",
          description: "Select an option from the menu.",
        );
      case 'applications':
        return const ApplicationsPanelPage(key: ValueKey('applications'));
      case 'categories':
        return const CategoriesPanelPage(key: ValueKey('categories'));
      case 'gradient':
        return const GradientPanelPage(key: ValueKey('gradient'));
      case 'wallpaper':
        return const WallpaperPanelPage(key: ValueKey('wallpaper'));
      default:
        return const ContentPanel(
          key: ValueKey('default'),
          title: "Home",
          description: "Select an option from the menu.",
        );
    }
  }
}

/// A simple content panel.
class ContentPanel extends StatelessWidget {
  final String title;
  final String description;
  const ContentPanel({
    super.key,
    required this.title,
    required this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool autofocus;
  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.autofocus = false,
  });
  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor =
        widget.isSelected
            ? Colors.lightBlueAccent.withOpacity(0.4)
            : Colors.white.withOpacity(0.1);
    final Color focusColor = Colors.lightBlueAccent.withOpacity(0.6);
    return FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onTap();
            _focusNode.requestFocus();
            return null;
          },
        ),
      },
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
        if (hasFocus) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: GestureDetector(
        onTap: () {
          debugPrint("Tapped?");
          widget.onTap();
          _focusNode.requestFocus();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isFocused ? focusColor : baseColor,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      widget.isSelected
                          ? Border.all(color: Colors.lightBlueAccent, width: 2)
                          : null,
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: Colors.lightBlueAccent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SwitchTile extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const SwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  State<SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        _isFocused
            ? Colors.lightBlueAccent.withOpacity(0.4)
            : Colors.white.withOpacity(0.1);
    return FocusableActionDetector(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      // Add TV remote support: listen for the "select" (Enter/OK) key press.
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onChanged(!widget.value);
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Switch(
                value: widget.value,
                onChanged: widget.onChanged,
                activeColor: Colors.lightBlueAccent,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
