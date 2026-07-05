import { defineConfig } from "drizzle-kit"

export default defineConfig({
    dialect: "postgresql",
    schema: "./db/schema.ts",
    out: "./drizzle",
    dbCredentials: {
        host: "://render.com",
        port: 5432,
        database: "memories_databse",
        user: "memories_databse_user",
        password: "HkfCODKKHUyFSqljvengkHuaisCF5gPi",
        ssl: true
    },
})