import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recorod_to_text/models/record_title.dart';

class RowRecordTitle extends StatefulWidget {
  const RowRecordTitle({super.key, required this.recordOnlyTitle, required this.isSelected, required this.onTap});

  final RecordOnlyTitle recordOnlyTitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  State<RowRecordTitle> createState() => _RowRecordTitleState();
}

class _RowRecordTitleState extends State<RowRecordTitle> {
  bool _isHovering = false;
  bool _isEditing = false;
  String _originalTitle = "";
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.recordOnlyTitle.title;
    _originalTitle = widget.recordOnlyTitle.title;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        setState(() => _isEditing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: ListTile(
        title: _listTileTitle(),
        trailing: _listTileTrailing(),
        onTap: widget.onTap,
        selected: widget.isSelected,
      ),
    );
  }

  Widget _listTileTitle() {
    if (_isEditing) {
      return Focus(
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
            setState(() {
              _controller.text = _originalTitle;
              _isEditing = false;
            });
            _focusNode.unfocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onSubmitted: (value) {
            // TODO 入力した内容をDBに反映する
            setState(() => _isEditing = false);
          },
        ),
      );
    } else {
      return Text(
        _controller.text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: (widget.onTap != null) ? null : Colors.grey),
      );
    }
  }

  Widget? _listTileTrailing() {
    if (_isHovering && !_isEditing) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
            _focusNode.requestFocus();
          },
          icon: const Icon(Icons.edit),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
