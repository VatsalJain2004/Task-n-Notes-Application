import express from "express";
import authRouter from "./routes/auth";
import taskRouter from "./routes/tasks";

const app = express();

app.use(express.json());
app.use('/auth', authRouter);
app.use('/tasks', taskRouter);

app.listen(8000, '0.0.0.0', () => { //, '0.0.0.0'
    console.log(`Server is live at PORT: 8000`);
})