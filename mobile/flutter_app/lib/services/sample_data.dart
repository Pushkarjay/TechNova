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
    final samples = [
      {
        'title': 'Placement - Mumbai',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Mumbai',
        'violationType': 'Placement',
        'aiSuggestion': 'Detected obtrusive placement',
        'lat': 19.0760,
        'lng': 72.8777,
      },
      {
        'title': 'Size - Delhi',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Delhi',
        'violationType': 'Size',
        'aiSuggestion': 'Large billboard exceeds guidelines',
        'lat': 28.6139,
        'lng': 77.2090,
      },
      {
        'title': 'Content - Bangalore',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Bangalore',
        'violationType': 'Content',
        'aiSuggestion': 'Potentially offensive content',
        'lat': 12.9716,
        'lng': 77.5946,
      },
      {
        'title': 'Size - Pune',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Pune',
        'violationType': 'Size',
        'aiSuggestion': 'Large billboard exceeds guidelines',
        'lat': 18.5204,
        'lng': 73.8567,
      },
      {
        'title': 'Placement - Hyderabad',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Hyderabad',
        'violationType': 'Placement',
        'aiSuggestion': 'Obtrusive placement near pedestrian path',
        'lat': 17.3850,
        'lng': 78.4867,
      },
      {
        'title': 'Hazard - Kolkata',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Kolkata',
        'violationType': 'Hazard',
        'aiSuggestion': 'Structural damage detected',
        'lat': 22.5726,
        'lng': 88.3639,
      },
      {
        'title': 'Content - Chennai',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Chennai',
        'violationType': 'Content',
        'aiSuggestion': 'Contains potentially objectionable content',
        'lat': 13.0827,
        'lng': 80.2707,
      },
      {
        'title': 'Size - Ahmedabad',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Ahmedabad',
        'violationType': 'Size',
        'aiSuggestion': 'Appears oversized for permitted zoning',
        'lat': 23.0225,
        'lng': 72.5714,
      },
      {
        'title': 'Placement - Surat',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Surat',
        'violationType': 'Placement',
        'aiSuggestion': 'Blocking sightlines / traffic sign',
        'lat': 21.1702,
        'lng': 72.8311,
      },
      {
        'title': 'Hazard - Lucknow',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Lucknow',
        'violationType': 'Hazard',
        'aiSuggestion': 'Damage to supporting structure',
        'lat': 26.8467,
        'lng': 80.9462,
      },
      {
        'title': 'Content - Jaipur',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Jaipur',
        'violationType': 'Content',
        'aiSuggestion': 'Potentially misleading content',
        'lat': 26.9124,
        'lng': 75.7873,
      },
      {
        'title': 'Size - Kanpur',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Kanpur',
        'violationType': 'Size',
        'aiSuggestion': 'Exceeds permitted billboard size',
        'lat': 26.4499,
        'lng': 80.3319,
      },
      {
        'title': 'Placement - Nagpur',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Nagpur',
        'violationType': 'Placement',
        'aiSuggestion': 'Too close to road shoulder',
        'lat': 21.1458,
        'lng': 79.0882,
      },
      {
        'title': 'Hazard - Indore',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Indore',
        'violationType': 'Hazard',
        'aiSuggestion': 'Unstable structure detected',
        'lat': 22.7196,
        'lng': 75.8577,
      },
      {
        'title': 'Content - Goa',
        'imagePath':
            'https://via.placeholder.com/400x300.png?text=Billboard+Goa',
        'violationType': 'Content',
        'aiSuggestion': 'Advert content flagged by rules',
        'lat': 15.2993,
        'lng': 74.1240,
      },
    ];

    for (var s in samples) {
      await local.insertReport({
        'title': s['title'],
        'imagePath': s['imagePath'],
        'violationType': s['violationType'],
        'aiSuggestion': s['aiSuggestion'],
        'lat': s['lat'],
        'lng': s['lng'],
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0,
      });
    }
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
