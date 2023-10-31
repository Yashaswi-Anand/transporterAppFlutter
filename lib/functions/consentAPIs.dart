import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';

// To send the consent to the user to allow sim based tracking this function are used
Future<Map<String, dynamic>> consentApiCall(
    {String? mobileNumber, String? operator}) async {
  final String consentApiUrl = FlutterConfig.get('consentApiUrl').toString();

  final Map<String, dynamic> requestBody = {
    'mobileNumber': mobileNumber,
    'operatorName': operator,
  };
  final String requestBodyJson = json.encode(requestBody);
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  final response = await http.post(
    Uri.parse(consentApiUrl),
    headers: headers,
    body: requestBodyJson,
  );
  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body) as Map<String, dynamic>;
    return responseBody;
  } else {
    throw Exception(
        "API Request Failed with Status Code: ${response.statusCode}");
  }
}
