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

import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:provider/provider.dart';

class GradientPanelPage extends StatelessWidget {
  static const String routeName = "gradient_panel";

  const GradientPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For big-screen design, consider scaling text, spacing, etc.

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            // You can tweak crossAxisCount depending on layout/orientation.
            crossAxisCount: 2,
            // Spacing scaled up for better TV readability
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            // A slightly more square ratio, adjust if you prefer wider/higher cards
            childAspectRatio: 4 / 3,
            padding: const EdgeInsets.all(16),
            children:
                FLauncherGradients.all
                    .map(
                      (gradient) => EnsureVisible(
                        alignment: 0.5,
                        child: _AnimatedGradientCard(
                          fLauncherGradient: gradient,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}

/// A custom widget to wrap each gradient card, handling focus, hover, and animations.
class _AnimatedGradientCard extends StatefulWidget {
  final FLauncherGradient fLauncherGradient;

  const _AnimatedGradientCard({required this.fLauncherGradient});

  @override
  State<_AnimatedGradientCard> createState() => _AnimatedGradientCardState();
}

class _AnimatedGradientCardState extends State<_AnimatedGradientCard> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    // We'll track focus using a Focus node + FocusableActionDetector for advanced control
    return FocusableActionDetector(
      key: Key("gradient-${widget.fLauncherGradient.uuid}"),
      onFocusChange: (focused) {
        setState(() => _hasFocus = focused);
      },
      // Add these lines:
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            context.read<WallpaperService>().setGradient(
              widget.fLauncherGradient,
            );
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: () {
          context.read<WallpaperService>().setGradient(
            widget.fLauncherGradient,
          );
        },
        child: _buildAnimatedCard(context),
      ),
    );
  }

  Widget _buildAnimatedCard(BuildContext context) {
    final gradient = widget.fLauncherGradient.gradient;
    final name = widget.fLauncherGradient.name;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _hasFocus ? 1.05 : 1.0,
        child: AnimatedPhysicalModel(
          duration: const Duration(milliseconds: 150),
          shape: BoxShape.rectangle,
          elevation: _hasFocus ? 8 : 2,
          shadowColor: Colors.black54,
          color: Colors.transparent, // base color for the Card
          borderRadius: BorderRadius.circular(
            16,
          ), // updated for rounder corners
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: _cardBorder(_hasFocus),
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
              // We'll position the label at the bottom or top if we want
              child: _buildLabel(context, name),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String name) {
    // On TVs, it might be nice to add a semi-transparent overlay for readability
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color:
                _hasFocus
                    ? Colors.black54
                    : Colors.black26, // highlight if in focus
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: AnimatedDefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 14,
                color: Colors.white,
                decoration: TextDecoration.none,
                fontWeight: _hasFocus ? FontWeight.bold : FontWeight.normal,
              ),
              duration: const Duration(milliseconds: 150),
              child: Text(name, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }

  ShapeBorder? _cardBorder(bool hasFocus) {
    return RoundedRectangleBorder(
      side:
          hasFocus
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
      borderRadius: BorderRadius.circular(16), // updated for rounder corners
    );
  }
}
