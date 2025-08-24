import 'local_storage.dart';

class SampleData {
  static Map<String, dynamic> sampleUser() {
    return {
      'id': 'demo-user-1',
      'displayName': 'Demo Operator',
      'email': 'demo@local'
    };
  }

  static Future<void> seedLocalReports() async {
    final local = LocalStorage();
    // Two sample entries with placeholder image paths (these can be local files or URLs)
    await local.insertReport({
      'imagePath':
          'https://via.placeholder.com/400x300.png?text=Billboard+Mumbai',
      'violationType': 'Placement',
      'aiSuggestion': 'Detected obtrusive placement',
      'lat': 19.0760,
      'lng': 72.8777,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': 0,
    });

    await local.insertReport({
      'imagePath':
          'https://via.placeholder.com/400x300.png?text=Billboard+Delhi',
      'violationType': 'Size',
      'aiSuggestion': 'Large billboard exceeds guidelines',
      'lat': 28.6139,
      'lng': 77.2090,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  static final List<Map<String, dynamic>> _samples = [
    {
      'id': 'sample-1',
      'violationType': 'Placement',
      'aiSuggestion': 'Detected obtrusive placement',
      'status': 'unauthorized',
      'lat': 19.0760,
      'lng': 72.8777,
      'imageUrl':
          'https://via.placeholder.com/400x300.png?text=Billboard+Mumbai'
    },
    {
      'id': 'sample-2',
      'violationType': 'Size',
      'aiSuggestion': 'Large billboard exceeds guidelines',
      'status': 'authorized',
      'lat': 28.6139,
      'lng': 77.2090,
      'imageUrl': 'https://via.placeholder.com/400x300.png?text=Billboard+Delhi'
    },
    {
      'id': 'sample-3',
      'violationType': 'Content',
      'aiSuggestion': 'Potentially offensive content',
      'status': 'unauthorized',
      'lat': 12.9716,
      'lng': 77.5946,
      'imageUrl':
          'https://via.placeholder.com/400x300.png?text=Billboard+Bangalore'
    }
  ];

  static Map<String, dynamic> getRandomReport() {
    _samples.shuffle();
    return _samples.first;
  }
}
