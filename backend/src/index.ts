import express from "express";
import authRouter from "./routes/auth";
import taskRouter from "./routes/tasks";

const app = express();
const PORT = 8000;

app.use(express.json());
app.use('/auth', authRouter);
app.use('/tasks', taskRouter);

app.listen(PORT, () => { //, '0.0.0.0'
  console.log(`Server is live at PORT: http://localhost:${PORT}`);
})