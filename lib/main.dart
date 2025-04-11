import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            labels: ['Profile', 'Messages', 'Call', 'Camera', 'Photos'],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items, required this.labels});

  final List<IconData> items;
  final List<String> labels;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  late List<String> _labels;
  int? hoveredIndex;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _labels = List.from(widget.labels);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final icon = _items.removeAt(oldIndex);
      _items.insert(newIndex, icon);

      final label = _labels.removeAt(oldIndex);
      _labels.insert(newIndex, label);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit:
              (_) => setState(() {
                isHovered = false;
                hoveredIndex = null;
              }),
          child: AnimatedScale(
            scale: isHovered ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_items.length, (index) {
                  final icon = _items[index];

                  return MouseRegion(
                    onEnter: (_) => setState(() => hoveredIndex = index),
                    onExit: (_) => setState(() => hoveredIndex = null),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Draggable<int>(
                          data: index,
                          feedback: buildDockItem(icon, isDragging: true),
                          childWhenDragging: const SizedBox(width: 56),
                          child: DragTarget<int>(
                            onAcceptWithDetails:
                                (details) => _onReorder(details.data, index),
                            builder: (context, candidateData, rejectedData) {
                              return AnimatedScale(
                                scale: candidateData.isNotEmpty ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                child: buildDockItem(icon),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),

        if (hoveredIndex != null)
          Positioned(
            top: -60,
            left: _getLabelPosition(context),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _labels[hoveredIndex!],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(
                    color: Colors.black87,
                    height: 10,
                    width: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  double _getLabelPosition(BuildContext context) {
    if (hoveredIndex == null) return 0;
    const double itemWidth = 60; // Approximated width of each dock item
    const double dockPadding = 12;
    double offset = (hoveredIndex! * itemWidth) + dockPadding;
    return offset;
  }

  Widget buildDockItem(IconData icon, {bool isDragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            isDragging
                ? [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ]
                : [],
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
