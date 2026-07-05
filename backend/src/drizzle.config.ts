import { defineConfig } from "drizzle-kit"

export default defineConfig({
    dialect: "postgresql",
    schema: "./src/db/schema.ts",
    out: "./drizzle",
    dbCredentials: {
        url: "postgresql://memories_databse_user:HkfCODKKHUyFSqljvengkHuaisCF5gPi@dpg-d955an9oagis738h3t60-a.oregon-postgres.render.com/memories_databse",
        ssl: true
    },
})