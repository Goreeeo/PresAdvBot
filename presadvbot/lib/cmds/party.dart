import 'dart:convert';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:presadvbot/managers/env.dart';

final party = SlashCommandBuilder("party", "Party settings.", [setPartyLeader],
    requiredPermissions: PermissionsConstants.administrator);

final setPartyLeader = CommandOptionBuilder(
    CommandOptionType.subCommand, "leader", "Sets a party leader.",
    options: [
      CommandOptionBuilder(CommandOptionType.string, "party_acronym",
          "The acronym of the party.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.user, "party_leader", "The leader of the party.",
          required: true)
    ])
  ..registerHandler((event) async {
    Map<String, dynamic> jsonMap = {
      "acronym": event.getArg("party_acronym").value,
      "leader": event.getArg("party_leader").value,
      "key": Environment.getValue("DB_ACCESS_KEY")
    };
    String body = json.encode(jsonMap);

    final uri = Uri.parse("http://localhost:7592/setPartyLeader");
    final headers = {"Content-Type": "application/json"};
    final encoding = Encoding.getByName("utf-8");

    Response response = await post(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    int statusCode = response.statusCode;

    if (statusCode == 200) {
      await event.respond(MessageBuilder.content(
          "Registered party leader as <@${event.getArg("party_leader").value}>."));
    } else {
      await event.respond(MessageBuilder.content("Unknown error."));
    }
  });
