import mongoose from "mongoose";

const schema = new mongoose.Schema({
    _id: {
        type: String,
        required: true,
    },
    name: {
        type: String,
        required: true
    },
    role: {
        type: String,
        required: true
    },
    channel: {
        type: String,
        required: true
    },
    leader: {
        type: String,
        required: false
    },
    running_poll: {
        type: mongoose.Schema.Types.ObjectId, ref: "polls",
        required: false
    }
});

export default mongoose.model("parties", schema);