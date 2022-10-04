import * as dotenv from "dotenv";
import mongoose from "mongoose";

dotenv.config();

class Mongo {
    private static instance: Mongo;

    private constructor() {}

    public static getInstance(): Mongo {
        if (!Mongo.instance) {
            Mongo.instance = new Mongo();
        }

        return Mongo.instance;
    }

    public get() {
        return mongoose;
    }

    public open() {
        mongoose.connect(process.env.MONGO_DB as string, { keepAlive: true }).then(() => {
            console.log("Connected to mongo.");
            return;
        })
    }

    public async close() {
        await mongoose.connection.close();
    }
}

export default Mongo;