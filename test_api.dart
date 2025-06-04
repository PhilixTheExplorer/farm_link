import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'http://localhost:3000/api';

  print('Testing API connection...');

  try {
    // Test health check
    print('1. Testing health check...');
    final healthUri = Uri.parse('http://localhost:3000/health');
    final healthResponse = await http.get(healthUri);
    print('Health check status: ${healthResponse.statusCode}');
    print('Health check response: ${healthResponse.body}');

    // Test products endpoint
    print('\n2. Testing products endpoint...');
    final productsUri = Uri.parse('$baseUrl/products');
    final productsResponse = await http.get(productsUri);
    print('Products status: ${productsResponse.statusCode}');
    print('Products response: ${productsResponse.body}');

    if (productsResponse.statusCode == 200) {
      final data = json.decode(productsResponse.body);
      print('Products data structure: ${data.keys}');
      if (data['data'] != null) {
        print('Number of products: ${data['data'].length}');
      }
    }
  } catch (e) {
    print('Error testing API: $e');
  }
}
