import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClear;
  
  const SearchTextField({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    this.onClear,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newQuery = _controller.text.trim().toLowerCase();
    if (newQuery != _searchQuery) {
      setState(() {
        _searchQuery = newQuery;
      });
      widget.onSearchChanged(newQuery);
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          // Handled by controller listener
        },
      ),
    );
  }
}