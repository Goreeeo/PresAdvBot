import express from "express";
import Mongo from "./mongo/mongo";
import * as partySchema from "./mongo/schema/party";
import * as dotenv from "dotenv";
import * as pollSchema from "./mongo/schema/poll";
import * as userSchema from "./mongo/schema/user";

dotenv.config();

const app = express();
const port = 7592;

app.use(express.json());

Mongo.getInstance().open();

app.get("/getParty/:id", async(req, res) => {
    const party = await partySchema.default.findOne({ _id: req.params.id });

    if (party) {
        res.send(party.toJSON());
    } else {
        res.sendStatus(404);
    }
});

app.get("/getPartyLeader/:id", async(req, res) => {
    const party = await partySchema.default.findOne({ _id: req.params.id });

    if (party && party.leader) {
        res.send(party.leader);
    } else {
        res.sendStatus(404);
    }
});

app.post("/setParty", async(req, res) => {
    if (req.body.key !== process.env.ACCESS_KEY) res.sendStatus(401);
    await partySchema.default.findOneAndUpdate({ _id: req.body.acronym }, { _id: req.body.acronym, name: req.body.name, role: req.body.role, channel: req.body.channel }, { upsert: true });
    res.send("Done.");
});

app.post("/setPartyLeader", async(req, res) => {
    if (req.body.key !== process.env.ACCESS_KEY) res.sendStatus(401);
    await partySchema.default.findOneAndUpdate({ _id: req.body.acronym }, { _id: req.body.acronym, leader: req.body.leader }, { upsert: true });
    res.send("Done.");
});

app.post("/startPoll", async(req, res) => {
    if (req.body.key !== process.env.ACCESS_KEY) res.sendStatus(401);
    const pollOptions = [req.body.options[0], req.body.options[1]];
    for (let i = 2; i < 5; i++) {
        if (req.body.options[i]) {
            pollOptions[i] = req.body.options[i];
        } else break;
    }
    await pollSchema.default.findOneAndUpdate({ _id: req.body.party }, { _id: req.body.party, channel: req.body.channel, message: req.body.message, question: req.body.question, options: pollOptions }, { upsert: true });
    await partySchema.default.findOneAndUpdate({ _id: req.body.party }, { _id: req.body.party, running_poll: true }, { upsert: true });
    res.send("Done.");
});

app.post("/endPoll", async(req, res) => {
    if (req.body.key !== process.env.ACCESS_KEY) res.sendStatus(401);
    await partySchema.default.findOneAndUpdate({ _id: req.body.party }, { _id: req.body.party, running_poll: false });
    const poll = await pollSchema.default.findOne({ _id: req.body.party });
    res.send(poll?.toJSON());
});

app.get("/pollRes/:party", async(req, res) => {
    const poll = await pollSchema.default.findOne({ _id: req.params.party });

    if (poll) {
        res.send(poll.toJSON());
    } else {
        res.sendStatus(404);
    }
});

app.get("/getMoney/:user", async(req, res) => {
    const user = await userSchema.default.findOne({ _id: req.params.user });
    if (user && user.money) {
        res.send(user?.money?.toString());
    } else {
        res.send("0".toString());
    }
});

app.post("/setMoney", async(req, res) => {
    if (req.body.key !== process.env.ACCESS_KEY) res.sendStatus(401);
    await userSchema.default.findOneAndUpdate({ _id: req.body.user }, { _id: req.body.user, money: Number.parseInt(req.body.money) }, { upsert: true });
    res.send("Done!");
});

app.listen(port, () => {
    console.log(`Server started at port ${port}.`)
});

process.on("SIGINT", function() {
    Mongo.getInstance().close().then(() => {
        console.log("Closed all mongo connections.");
        process.exit(0);
    });
})