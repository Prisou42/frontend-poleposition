class ApiConfig {
  static const String baseUrl =
      'https://poleposition-api.onrender.com';

  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;

    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }
}