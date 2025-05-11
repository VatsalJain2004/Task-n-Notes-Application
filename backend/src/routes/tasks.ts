import { Router } from "express";
import { auth, AuthRequest } from "../middleware/auth";
import { NewTask, tasks, users } from "../db/schema";
import { db } from "../db";
import { eq } from "drizzle-orm";

const taskRouter = Router();

taskRouter.post("/", auth, async (req: AuthRequest, res) => {
  try {
    req.body = { ...req.body, dueAt: new Date(req.body.dueAt), uid: req.user };
    const newTasks: NewTask = req.body;

    const [task] = await db.insert(tasks).values(newTasks).returning();

    res.status(201).json(task);
  }
  catch (error) {
    console.log(`error: ${error}`);
    res.status(500).json({ error: error });
  }
})

taskRouter.get("/", auth, async (req: AuthRequest, res) => {
  try {
    const allTasks = await db.select().from(tasks).where(eq(tasks.uid, req.user!));

    res.status(201).json(allTasks);
  }
  catch (error) {
    res.status(500).json({ error: error });
  }
})


taskRouter.delete("/", auth, async (req: AuthRequest, res) => {
  try {
    const { taskId }: { taskId: string } = req.body;

    await db.delete(tasks).where(eq(tasks.id, taskId));

    res.status(201).json(true);
  }
  catch (error) {
    res.status(500).json({ error: error });
  }
})

export default taskRouter;