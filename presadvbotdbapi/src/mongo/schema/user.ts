import mongoose from "mongoose";

const schema = new mongoose.Schema({
    _id: {
        type: String,
        required: true
    },
    money: {
        type: Number,
        required: false,
    }
})

export default mongoose.model("users", schema);