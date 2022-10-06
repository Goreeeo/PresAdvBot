import mongoose from "mongoose";

const schema = new mongoose.Schema({
    _id: {
        type: String,
        required: true
    },
    channel: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    question: {
        type: String,
        required: true,
    },
    options: {
        type: [String],
        required: true,
    }
});

export default mongoose.model("polls", schema);