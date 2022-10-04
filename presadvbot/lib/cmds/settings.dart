import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:presadvbot/managers/mongo.dart';

final register =
    SlashCommandBuilder("register", "Registers things.", [registerParty]);

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
          required: true)
    ])
  ..registerHandler((event) async {
    await event.respond(MessageBuilder.content("Registered party."));
  });
