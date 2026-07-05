import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

const DATABASE_URL = "postgresql://memories_databse_user:HkfCODKKHUyFSqljvengkHuaisCF5gPi@dpg-d955an9oagis738h3t60-a.oregon-postgres.render.com/memories_databse";

const pool = new Pool({
    connectionString: DATABASE_URL,
    ssl: true
});


export const db = drizzle(pool);