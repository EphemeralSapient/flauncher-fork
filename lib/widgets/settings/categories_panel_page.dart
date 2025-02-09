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

import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/add_category_dialog.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flauncher/widgets/settings/category_panel_page.dart'
    show CategoryPanelPage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TVIconButton extends StatefulWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final double splashRadius;
  const TVIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.splashRadius = 28,
  });

  @override
  _TVIconButtonState createState() => _TVIconButtonState();
}

class _TVIconButtonState extends State<TVIconButton> {
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
          onInvoke: (intent) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              _isFocused
                  ? Colors.lightBlueAccent.withOpacity(0.3)
                  : Colors.transparent,
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(widget.splashRadius),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

class CategoriesPanelPage extends StatelessWidget {
  static const String routeName = "categories_panel";

  const CategoriesPanelPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 30),
      Selector<AppsService, List<CategoryWithApps>>(
        selector: (_, appsService) => appsService.categoriesWithApps,
        builder:
            (_, categories, __) => Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children:
                      categories
                          .asMap()
                          .keys
                          .map((index) => _category(context, categories, index))
                          .toList(),
                ),
              ),
            ),
      ),
      TextButton.icon(
        icon: Icon(Icons.add),
        label: Text("Add Category"),
        onPressed: () async {
          final categoryName = await showDialog<String>(
            context: context,
            builder: (_) => AddCategoryDialog(),
          );
          if (categoryName != null) {
            await context.read<AppsService>().addCategory(categoryName);
          }
        },
      ),
    ],
  );
  Widget _category(
    BuildContext context,
    List<CategoryWithApps> categories,
    int index,
  ) {
    // Wrap with FocusTraversalGroup so descendant widgets (like TVIconButton) receive focus.
    return FocusTraversalGroup(
      child: Builder(
        builder: (context) {
          // Check if any descendant is focused.
          final bool isDescendantFocused =
              FocusScope.of(context).focusedChild != null;
          final Color cardColor =
              isDescendantFocused
                  ? Colors.white.withOpacity(0.13)
                  : Colors.lightBlueAccent.withOpacity(0.1);
          return Padding(
            key: Key(categories[index].category.id.toString()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              margin: EdgeInsets.zero,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: EnsureVisible(
                alignment: 0.5,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  dense: false,
                  title: Text(
                    categories[index].category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(
                    'Category ID: ${categories[index].category.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TVIconButton(
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white70,
                          size: 28,
                        ),
                        onPressed:
                            () => _move(
                              context,
                              index,
                              index > 0 ? index - 1 : index,
                            ),
                      ),
                      const SizedBox(width: 4),
                      TVIconButton(
                        icon: const Icon(
                          Icons.arrow_downward,
                          color: Colors.white70,
                          size: 28,
                        ),
                        onPressed:
                            () => _move(
                              context,
                              index,
                              index < categories.length - 1 ? index + 1 : index,
                            ),
                      ),
                      const SizedBox(width: 4),
                      TVIconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white70,
                          size: 28,
                        ),
                        onPressed:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => CategoryPanelPage(categoryId: index),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _move(BuildContext context, int oldIndex, int newIndex) async {
    await context.read<AppsService>().moveCategory(oldIndex, newIndex);
  }
}
