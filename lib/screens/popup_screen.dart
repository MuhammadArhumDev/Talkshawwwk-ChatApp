import 'package:flutter/material.dart';

class CustomPopupExample extends StatefulWidget {
  static const String id = 'custompopup';
  const CustomPopupExample({super.key});

  @override
  State<CustomPopupExample> createState() => _CustomPopupExampleState();
}

class _CustomPopupExampleState extends State<CustomPopupExample> {
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _togglePopup() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + renderBox.size.height,
              left: offset.dx - 150 + renderBox.size.width,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMenuItem("Settingsss", Icons.settings),
                    _buildMenuItem("Help", Icons.help_outline),
                    _buildMenuItem("Logout", Icons.logout),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildMenuItem(String text, IconData icon) {
    return InkWell(
      onTap: () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.amberAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Popup Menu"),
        actions: [
          IconButton(
            key: _menuKey,
            icon: const Icon(Icons.more_vert),
            onPressed: _togglePopup,
          ),
        ],
      ),
      body: const Center(child: Text("Tap 3 dots in top right")),
    );
  }
}
