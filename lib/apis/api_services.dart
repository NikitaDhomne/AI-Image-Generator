import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_generator/apis/api_key.dart';

class Api {
  static final url = "https://api.openai.com/v1/images/generations";
  static final headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $apiKey"
  };

  static generateImage(String text) async {
    var res = await http.post(Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          "prompt": text,
          "n": 1,
          "size": "512x512",
        }));
    print(".............");
    print(res.statusCode);

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());
      // print(data.toString());
      return data["data"][0]["url"].toString();
    } else {
      print("Failed to fetch image");
    }
  }
}
