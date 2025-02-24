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

class AddCategoryDialog extends StatelessWidget {
  final String? initialValue;

  const AddCategoryDialog({super.key, this.initialValue});

  @override
  Widget build(BuildContext context) => SimpleDialog(
    insetPadding: EdgeInsets.only(bottom: 120),
    contentPadding: EdgeInsets.all(24),
    title: Text(initialValue != null ? "Rename Category" : "Add Category"),
    children: [
      TextFormField(
        autofocus: true,
        initialValue: initialValue,
        decoration: InputDecoration(labelText: "Name"),
        validator:
            (value) => value!.trim().isEmpty ? "Must not be empty" : null,
        autovalidateMode: AutovalidateMode.always,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        onFieldSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.of(context).pop(value);
          }
        },
      ),
    ],
  );
}
