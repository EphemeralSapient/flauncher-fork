/*
 * ModernTvSettingsPage
 * Copyright (C) 2021  Étienne Fesser
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

import 'package:flutter/material.dart';

/// A simple content panel that displays a title and description.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

/// A custom menu button that uses FocusableActionDetector to handle focus
/// (which is important for TV remotes) and provides a subtle animated scaling effect.
class MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// If true, this button will request focus automatically.
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
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    // Use different background colors depending on focus and selection.
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

/// A custom switch tile that is fully focusable and reacts to remote input.
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
        child: Container(
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
