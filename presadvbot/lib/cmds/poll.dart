import 'dart:convert';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:presadvbot/managers/env.dart';
import 'package:presadvbot/managers/rest.dart';

final poll = SlashCommandBuilder("poll", "Poll something", [partyPoll, end]);

final end = CommandOptionBuilder(
    CommandOptionType.subCommandGroup, "end", "Ends a poll.",
    options: [endPartyPoll]);

final endPartyPoll = CommandOptionBuilder(
    CommandOptionType.subCommand, "party", "End a party poll.",
    options: [
      CommandOptionBuilder(CommandOptionType.string, "party_acronym",
          "Acronym of the polling party.")
    ])
  ..registerHandler((event) async {
    Map<String, dynamic> jsonMap = {
      "party": event.getArg("party_acronym").value,
      "key": Environment.getValue("DB_ACCESS_KEY")
    };
    String body = json.encode(jsonMap);

    final uri = Uri.parse("http://localhost:7592/startPoll/");
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
      await event.respond(MessageBuilder.content("No active poll running."));
      return;
    }

    Map<String, dynamic> poll = jsonDecode(response.body);

    final msg = await (event.interaction.guild!
                .getFromCache()!
                .channels
                .singleWhere((element) => element.id == poll["channel"])
            as ITextGuildChannel)
        .fetchMessage(poll["message"]);

    Map<int, int> votes = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
    };

    for (var reaction in msg.reactions) {
      if (reaction.emoji == UnicodeEmoji('1️⃣')) {
        votes[1] = votes[1]!.toInt() + 1;
      } else if (reaction.emoji == UnicodeEmoji('2️⃣')) {
        votes[2] = votes[2]!.toInt() + 1;
      } else if (reaction.emoji == UnicodeEmoji('3️⃣')) {
        votes[3] = votes[3]!.toInt() + 1;
      } else if (reaction.emoji == UnicodeEmoji('4️⃣')) {
        votes[4] = votes[4]!.toInt() + 1;
      } else if (reaction.emoji == UnicodeEmoji('5️⃣')) {
        votes[5] = votes[5]!.toInt() + 1;
      } else if (reaction.emoji == UnicodeEmoji('6️⃣')) {
        votes[6] = votes[6]!.toInt() + 1;
      }
    }
  });

final partyPoll = CommandOptionBuilder(
    CommandOptionType.subCommand, "party", "Poll something for your party.",
    options: [
      CommandOptionBuilder(
          CommandOptionType.string, "party_acronym", "The party acronym.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "question", "The question to ask.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "option_one", "The first option.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "option_two", "The second option.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "option_three", "The third option.",
          required: false),
      CommandOptionBuilder(
          CommandOptionType.string, "option_four", "The fourth option.",
          required: false),
      CommandOptionBuilder(
          CommandOptionType.string, "option_five", "The fifth option.",
          required: false),
      CommandOptionBuilder(
          CommandOptionType.string, "option_six", "The sixth option.",
          required: false),
    ])
  ..registerHandler((event) async {
    final Uri uri = Uri.parse(
        "http://localhost:7592/getParty/${event.getArg("party_acronym").value}");

    Map<String, dynamic>? party =
        await restGet(uri, "Non-existent party.", event);

    if (party == null) {
      return;
    }

    var perm = event.interaction.memberAuthorPermissions;

    if ((perm != null &&
            perm.hasPermission(PermissionsConstants.administrator)) ||
        event.interaction.userAuthor?.id.id.toString() == party["leader"]) {
      final guild = event.interaction.guild!.getFromCache();
      final channel = guild!.channels
          .singleWhere((element) => element.id == party["channel"]);

      EmbedBuilder embed = EmbedBuilder();
      embed.addAuthor((author) {
        author.name = event.interaction.memberAuthor?.nickname ??
            event.interaction.userAuthor?.username;
        author.iconUrl = event.interaction.memberAuthor?.avatarURL() ??
            event.interaction.userAuthor?.avatarURL();
      });
      embed.title = event.getArg("question").value as String;
      embed.addField(
          name: "Option 1", content: event.getArg("option_one").value);
      embed.addField(
          name: "Option 2", content: event.getArg("option_two").value);
      try {
        embed.addField(
            name: "Option 3", content: event.getArg("option_three").value);
      } catch (exception) {}
      try {
        embed.addField(
            name: "Option 4", content: event.getArg("option_four").value);
      } catch (exception) {}
      try {
        embed.addField(
            name: "Option 5", content: event.getArg("option_five").value);
      } catch (exception) {}
      try {
        embed.addField(
            name: "Option 6", content: event.getArg("option_six").value);
      } catch (exception) {}

      final msg = await (channel as ITextGuildChannel)
          .sendMessage(MessageBuilder.embed(embed));

      await msg.createReaction(UnicodeEmoji('1️⃣'));
      await msg.createReaction(UnicodeEmoji('2️⃣'));
      try {
        event.getArg("option_three");
        await msg.createReaction(UnicodeEmoji('3️⃣'));
      } catch (exception) {}
      try {
        event.getArg("option_four");
        await msg.createReaction(UnicodeEmoji('4️⃣'));
      } catch (exception) {}
      try {
        event.getArg("option_five");
        await msg.createReaction(UnicodeEmoji('5️⃣'));
      } catch (exception) {}
      try {
        event.getArg("option_six");
        await msg.createReaction(UnicodeEmoji('6️⃣'));
      } catch (exception) {}

      await event.respond(
          MessageBuilder.content("Created poll in <#${party["channel"]}>."));

      Map<String, dynamic> jsonMap = {
        "party": event.getArg("party_acronym").value,
        "channel": channel.id,
        "message": msg.id,
        "key": Environment.getValue("DB_ACCESS_KEY")
      };
      String body = json.encode(jsonMap);

      final uri = Uri.parse("http://localhost:7592/startPoll/");
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
        await event.sendFollowup(
            MessageBuilder.content("Poll creation failed internally."));
      }

      return;
    }

    await event.respond(
        MessageBuilder.content("You are not the leader of the party."));
  });
