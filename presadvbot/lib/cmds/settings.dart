import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:presadvbot/config.dart';
import 'package:presadvbot/managers/env.dart';

final register = SlashCommandBuilder(
    "register", "Registers things.", [registerParty],
    requiredPermissions: PermissionsConstants.administrator);

final registerParty = CommandOptionBuilder(
    CommandOptionType.subCommand, "party", "Register a party.",
    options: [
      CommandOptionBuilder(CommandOptionType.string, "party_name",
          "The name of the party. (full)",
          required: true),
      CommandOptionBuilder(CommandOptionType.string, "party_acronym",
          "The acronym of the party.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.role, "party_role", "The role of the party.",
          required: true),
      CommandOptionBuilder(CommandOptionType.channel, "party_channel",
          "The channel of the party.",
          required: true)
    ])
  ..registerHandler((event) async {
    try {
      Map<String, dynamic> jsonMap = {
        "acronym": event.getArg("party_acronym").value,
        "name": event.getArg("party_name").value,
        "role": event.getArg("party_role").value,
        "channel": event.getArg("party_channel").value,
        "key": Environment.getValue("DB_ACCESS_KEY")
      };
      String body = json.encode(jsonMap);

      final uri = Uri.parse("$restUrl/setParty");
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
        await event.respond(MessageBuilder.content("Registered party."));
      } else {
        await event.respond(MessageBuilder.content("Unknown error."));
      }
    } catch (ex) {
      await event.respond(MessageBuilder.content(
          "There has been an error, contact <@532297642559012884> with the steps to recreate it."));
    }
  });
