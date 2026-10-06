import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_radius.dart';

class PawDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool searchable;
  final String Function(T)? searchFilter;
  
  const PawDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.searchable = false,
    this.searchFilter,
  });
  
  @override
  State<PawDropdown<T>> createState() => _PawDropdownState<T>();
}

class _PawDropdownState<T> extends State<PawDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    if (widget.searchable) {
      return InkWell(
        onTap: widget.enabled ? _showSearchableDialog : null,
        borderRadius: BorderRadius.circular(PawRadius.input),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            enabled: widget.enabled,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(
            _getDisplayText(),
            style: PawTypography.bodyMedium,
          ),
        ),
      );
    }
    
    return DropdownButtonFormField<T>(
      initialValue: widget.value,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        enabled: widget.enabled,
      ),
      items: widget.items,
      onChanged: widget.enabled ? widget.onChanged : null,
      icon: const Icon(Icons.arrow_drop_down),
      dropdownColor: PawColors.cardBackground,
      style: PawTypography.bodyMedium,
    );
  }
  
  String _getDisplayText() {
    if (widget.value == null) {
      return widget.hint ?? '';
    }
    final item = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => widget.items.first,
    );
    return item.child.toString();
  }
  
  Future<void> _showSearchableDialog() async {
    final result = await showDialog<T>(
      context: context,
      builder: (context) => _SearchableDropdownDialog<T>(
        items: widget.items,
        currentValue: widget.value,
        searchFilter: widget.searchFilter,
      ),
    );
    
    if (result != null && widget.onChanged != null) {
      widget.onChanged!(result);
    }
  }
}

class _SearchableDropdownDialog<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? currentValue;
  final String Function(T)? searchFilter;
  
  const _SearchableDropdownDialog({
    required this.items,
    this.currentValue,
    this.searchFilter,
  });
  
  @override
  State<_SearchableDropdownDialog<T>> createState() =>
      _SearchableDropdownDialogState<T>();
}

class _SearchableDropdownDialogState<T>
    extends State<_SearchableDropdownDialog<T>> {
  late List<DropdownMenuItem<T>> _filteredItems;
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          if (widget.searchFilter != null && item.value != null) {
            return widget.searchFilter!(item.value as T)
                .toLowerCase()
                .contains(query.toLowerCase());
          }
          return true;
        }).toList();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(PawSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterItems,
                autofocus: true,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item.value == widget.currentValue;
                  
                  return ListTile(
                    title: item.child,
                    selected: isSelected,
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, item.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
