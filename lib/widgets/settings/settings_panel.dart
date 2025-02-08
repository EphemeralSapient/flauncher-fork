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
import 'dart:typed_data';
import 'dart:ui';

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
import 'package:package_info_plus/package_info_plus.dart';

class App {
  final String name;
  final bool sideloaded;
  final bool hidden;
  final Uint8List? icon;
  // For ApplicationInfoPanel example:
  final String packageName;
  final String version;
  App({
    required this.name,
    this.sideloaded = false,
    this.hidden = false,
    this.icon,
    this.packageName = "com.example.app",
    this.version = "1.0.0",
  });
}

class Category {
  final int id;
  String name;
  CategorySort sort;
  CategoryType type;
  int columnsCount;
  int rowHeight;
  Category({
    required this.id,
    required this.name,
    this.sort = CategorySort.alphabetical,
    this.type = CategoryType.row,
    this.columnsCount = 5,
    this.rowHeight = 100,
  });
}

enum CategorySort { alphabetical, manual }

enum CategoryType { row, grid }

class CategoryWithApps {
  final Category category;
  CategoryWithApps({required this.category});
}

class NoFileExplorerException implements Exception {}

class AppsService with ChangeNotifier {
  List<App> applications = [
    App(name: "TV App 1", sideloaded: false, hidden: false, icon: Uint8List(0)),
    App(
      name: "Non-TV App",
      sideloaded: true,
      hidden: false,
      icon: Uint8List(0),
    ),
    App(
      name: "Hidden App",
      sideloaded: false,
      hidden: true,
      icon: Uint8List(0),
    ),
  ];
  List<CategoryWithApps> categoriesWithApps = [
    CategoryWithApps(
      category: Category(id: 1, name: "Favorites", type: CategoryType.row),
    ),
    CategoryWithApps(
      category: Category(id: 2, name: "Games", type: CategoryType.grid),
    ),
  ];

  Future<void> addCategory(String categoryName) async {
    categoriesWithApps.add(
      CategoryWithApps(
        category: Category(
          id: categoriesWithApps.length + 1,
          name: categoryName,
        ),
      ),
    );
    notifyListeners();
  }

  Future<void> moveCategory(int oldIndex, int newIndex) async {
    final cat = categoriesWithApps.removeAt(oldIndex);
    categoriesWithApps.insert(newIndex, cat);
    notifyListeners();
  }

  Future<void> renameCategory(Category category, String newName) async {
    category.name = newName;
    notifyListeners();
  }

  Future<void> deleteCategory(Category category) async {
    categoriesWithApps.removeWhere(
      (catWithApps) => catWithApps.category.id == category.id,
    );
    notifyListeners();
  }

  void setCategorySort(Category category, CategorySort sort) {
    category.sort = sort;
    notifyListeners();
  }

  void setCategoryType(Category category, CategoryType type) {
    category.type = type;
    notifyListeners();
  }

  void setCategoryColumnsCount(Category category, int count) {
    category.columnsCount = count;
    notifyListeners();
  }

  void setCategoryRowHeight(Category category, int height) {
    category.rowHeight = height;
    notifyListeners();
  }

  // Dummy methods for ApplicationInfoPanel actions:
  Future<void> launchApp(App app) async {}
  Future<void> hideApplication(App app) async {}
  Future<void> unHideApplication(App app) async {}
  Future<void> removeFromCategory(App app, Category category) async {}
  Future<void> openAppInfo(App app) async {}
  Future<void> uninstallApp(App app) async {}

  // For reordering apps (dummy)
  void reorderApplication(Category category, int oldIndex, int newIndex) {}
  void saveOrderInCategory(Category category) {}
}

class WallpaperService with ChangeNotifier {
  Future<void> pickWallpaper() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void setGradient(FLauncherGradient gradient) {
    notifyListeners();
  }
}

class SettingsService with ChangeNotifier {
  String?
  unsplashAuthor; // e.g. '{"link": "https://unsplash.com", "username": "photog"}'
}

/// Dummy widget to ensure a child is visible when focused.
class EnsureVisible extends StatelessWidget {
  final Widget child;
  final double alignment;
  const EnsureVisible({super.key, required this.child, this.alignment = 0.5});
  @override
  Widget build(BuildContext context) => child;
}

/// Dummy dialog to add an app to a category.
class AddToCategoryDialog extends StatelessWidget {
  final App application;
  const AddToCategoryDialog(this.application, {super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add ${application.name} to Category"),
      content: const Text("Dummy dialog"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

/// Dummy dialog to add (or rename) a category.
class AddCategoryDialog extends StatelessWidget {
  final String? initialValue;
  const AddCategoryDialog({super.key, this.initialValue});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(initialValue == null ? "Add Category" : "Rename Category"),
      content: TextField(
        decoration: const InputDecoration(labelText: "Category Name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop("New Category"),
          child: const Text("OK"),
        ),
      ],
    );
  }
}

/// Dummy info panel for an application.
class ApplicationInfoPanel extends StatelessWidget {
  final Category? category;
  final App application;
  const ApplicationInfoPanel({
    super.key,
    required this.category,
    required this.application,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(application.name),
      content: const Text("Dummy application info"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

/// Dummy gradients used by GradientPanelPage.
class FLauncherGradient {
  final String uuid;
  final Gradient gradient;
  final String name;
  FLauncherGradient({
    required this.uuid,
    required this.gradient,
    required this.name,
  });
}

class FLauncherGradients {
  static final all = <FLauncherGradient>[
    FLauncherGradient(
      uuid: "1",
      gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
      name: "Sunset",
    ),
    FLauncherGradient(
      uuid: "2",
      gradient: LinearGradient(colors: [Colors.blue, Colors.green]),
      name: "Ocean",
    ),
  ];
  static final FLauncherGradient greatWhale = all[0];
}

/// Dummy WebView widget and controller.
class WebViewWidget extends StatelessWidget {
  final WebViewController controller;
  const WebViewWidget({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebView")),
      body: const Center(child: Text("WebView Content")),
    );
  }
}

class WebViewController {
  void loadRequest(Uri uri) {}
}

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

  @override
  Widget build(BuildContext context) {
    // Panel occupies about 50% of screen width and 70% of its height.
    final double panelWidth = MediaQuery.of(context).size.width * 0.5;
    final double panelHeight = MediaQuery.of(context).size.height * 0.7;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: panelWidth,
          height: panelHeight,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
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
                      color: Colors.black.withOpacity(0.3),
                      border: Border(
                        right: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 0,
                              bottom: 0,
                            ),
                            child: MenuButton(
                              icon: Icons.tv,
                              label: "Applications",
                              isSelected: _selectedPanel == 'applications',
                              autofocus: _selectedPanel == 'applications',
                              onTap: () {
                                setState(() {
                                  _selectedPanel = 'applications';
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 0,
                              bottom: 0,
                            ),
                            child: MenuButton(
                              icon: Icons.category,
                              label: "Categories",
                              isSelected: _selectedPanel == 'categories',
                              onTap: () {
                                setState(() {
                                  _selectedPanel = 'categories';
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 0,
                              bottom: 0,
                            ),
                            child: MenuButton(
                              icon: Icons.gradient,
                              label: "Gradient",
                              isSelected: _selectedPanel == 'gradient',
                              onTap: () {
                                setState(() {
                                  _selectedPanel = 'gradient';
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 0,
                              bottom: 0,
                            ),
                            child: MenuButton(
                              icon: Icons.wallpaper,
                              label: "Wallpaper",
                              isSelected: _selectedPanel == 'wallpaper',
                              onTap: () {
                                setState(() {
                                  _selectedPanel = 'wallpaper';
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 0,
                              bottom: 0,
                            ),
                            child: MenuButton(
                              icon: Icons.info_outline,
                              label: "About",
                              isSelected: false,
                              onTap: _showAboutDialog,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 0,
                              bottom: 0,
                            ),
                            child: SwitchTile(
                              label: "Use 24-hour time",
                              value: _use24HourTime,
                              onChanged: (val) {
                                setState(() {
                                  _use24HourTime = val;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 0,
                              bottom: 0,
                            ),
                            child: SwitchTile(
                              label: "Highlight Animation",
                              value: _highlightAnimation,
                              onChanged: (val) {
                                setState(() {
                                  _highlightAnimation = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right content area with animated slide/fade transition.
                  // Updated animation snippet for a TV-friendly settings panel
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

                        return SlideTransition(
                          position: slideAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
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

/// ************************************************************************
/// Custom Focusable Widgets for Remote Navigation with Enhanced Animations
/// ************************************************************************

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
