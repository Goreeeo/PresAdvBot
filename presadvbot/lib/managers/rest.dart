import 'dart:convert';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

Future<Map<String, dynamic>?> restGet(
    Uri uri, String error, ISlashCommandInteractionEvent event) async {
  Response response = await get(uri);

  if (response.statusCode != 200) {
    await event.respond(MessageBuilder.content(error));
    return null;
  }

  return jsonDecode(response.body);
}

Future<Map<String, dynamic>?> restPost(Uri uri, Map<String, dynamic> jsonMap,
    String error, ISlashCommandInteractionEvent event) async {
  String body = json.encode(jsonMap);
  final headers = {"Content-Type": "application/json"};
  final encoding = Encoding.getByName("utf-8");

  Response response = await post(
    uri,
    headers: headers,
    body: body,
    encoding: encoding,
  );

  int statusCode = response.statusCode;

  if (statusCode != 200) {
    await event.respond(MessageBuilder.content(error));
    return null;
  }

  return jsonDecode(response.body);
}
