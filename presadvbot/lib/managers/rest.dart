import 'dart:convert';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

Future<Map<String, dynamic>?> restGet(
    Uri uri, String error, ISlashCommandInteractionEvent event) async {
  return jsonDecode(await restGetStr(uri, error, event));
}

Future<String> restGetStr(
    Uri uri, String error, ISlashCommandInteractionEvent event) async {
  Response response = await get(uri);

  if (response.statusCode != 200) {
    await event.respond(MessageBuilder.content(error));
    return "";
  }

  return response.body;
}

Future<Map<String, dynamic>?> restPost(Uri uri, Map<String, dynamic> jsonMap,
    String error, ISlashCommandInteractionEvent event,
    {bool followUp = false}) async {
  String response = await restPostStr(uri, jsonMap, error, event);

  return jsonDecode(response);
}

Future<String> restPostStr(Uri uri, Map<String, dynamic> jsonMap, String error,
    ISlashCommandInteractionEvent event,
    {bool followUp = false}) async {
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
    followUp
        ? await event.sendFollowup(MessageBuilder.content(error))
        : await event.respond(MessageBuilder.content(error));
    return "null";
  }

  return response.body;
}
