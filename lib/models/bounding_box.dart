// lib/models/bounding_box.dart
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;
  final double confidence;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
    required this.confidence,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: json['x'],
      y: json['y'],
      width: json['w'],
      height: json['h'],
      label: json['label'],
      confidence: json['confidence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'w': width,
      'h': height,
      'label': label,
      'confidence': confidence,
    };
  }
}