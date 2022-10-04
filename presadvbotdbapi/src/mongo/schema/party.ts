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
    }
});

export default mongoose.model("parties", schema);