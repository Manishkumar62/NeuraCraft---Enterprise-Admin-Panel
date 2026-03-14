import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../domain/entities/module_entity.dart';

class ModulePermissionSelector extends StatelessWidget {
  final String title;
  final List<ModulePermissionEntity> items;
  final List<ModulePermissionEntity> selectedPermissions;
  final ValueChanged<List<ModulePermissionEntity>> onChanged;

  const ModulePermissionSelector({
    super.key,
    required this.title,
    required this.items,
    required this.selectedPermissions,
    required this.onChanged,
  });

  void _openSelector(BuildContext context) {
    final customLabelController = TextEditingController();
    final customCodenameController = TextEditingController();
    var customCategory = 'action';
    var showCustomForm = false;
    final tempItems = List<ModulePermissionEntity>.from(items);
    final tempSelected = List<ModulePermissionEntity>.from(selectedPermissions);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AppBottomSheet(
              title: title,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tempItems.map((item) {
                                final selected = tempSelected.any(
                                  (permission) => permission.codename == item.codename,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      if (selected) {
                                        tempSelected.removeWhere(
                                          (permission) =>
                                              permission.codename == item.codename,
                                        );
                                      } else {
                                        tempSelected.add(item);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selected
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.white24,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: selected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : null,
                                          ),
                                        ),
                                        if (selected) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.close, size: 14),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            if (!showCustomForm)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setModalState(() {
                                      showCustomForm = true;
                                    });
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add Custom Permission"),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  TextField(
                                    controller: customLabelController,
                                    decoration: InputDecoration(
                                      labelText: "Permission Label",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.02),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: customCodenameController,
                                    decoration: InputDecoration(
                                      labelText: "Permission Codename",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.02),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: customCategory,
                                    decoration: InputDecoration(
                                      labelText: "Category",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.02),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'crud',
                                        child: Text("CRUD"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'action',
                                        child: Text("Action"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'column',
                                        child: Text("Column"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'component',
                                        child: Text("Component"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'field',
                                        child: Text("Field"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setModalState(() {
                                        customCategory = value ?? 'action';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setModalState(() {
                                              showCustomForm = false;
                                              customLabelController.clear();
                                              customCodenameController.clear();
                                              customCategory = 'action';
                                            });
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final label =
                                                customLabelController.text.trim();
                                            final codename = customCodenameController
                                                    .text
                                                    .trim()
                                                    .isEmpty
                                                ? label
                                                    .toLowerCase()
                                                    .replaceAll(RegExp(r'\s+'), '_')
                                                : customCodenameController.text
                                                    .trim();

                                            if (label.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Permission label required",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            if (tempItems.any(
                                              (permission) =>
                                                  permission.codename == codename,
                                            )) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Permission already exists",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final permission =
                                                ModulePermissionEntity(
                                              codename: codename,
                                              label: label,
                                              category: customCategory,
                                            );

                                            setModalState(() {
                                              tempItems.add(permission);
                                              tempSelected.add(permission);
                                              showCustomForm = false;
                                              customLabelController.clear();
                                              customCodenameController.clear();
                                              customCategory = 'action';
                                            });
                                          },
                                          child: const Text("Add"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onChanged(tempSelected);
                          Navigator.pop(context);
                        },
                        child: const Text("Apply"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _openSelector(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: selectedPermissions.isEmpty
                ? const Text("Select", style: TextStyle(color: Colors.grey))
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: selectedPermissions.map((permission) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          permission.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
