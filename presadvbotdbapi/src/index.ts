import express from "express";
import Mongo from "./mongo/mongo";
import * as partySchema from "./mongo/schema/party";

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

app.post("/setParty", async(req, res) => {
    await partySchema.default.findOneAndUpdate({ _id: req.body.acronym }, { _id: req.body.acronym, name: req.body.name, role: req.body.role, channel: req.body.channel }, { upsert: true });
    res.send("Done.");
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