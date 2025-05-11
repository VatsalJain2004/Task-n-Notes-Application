import jwt from "jsonwebtoken";
import { Request, Response, Router } from "express";
import { db } from "../db";
import { NewUser, users } from "../db/schema";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import { UUID } from "crypto";
import { auth, AuthRequest } from "../middleware/auth";

const authRouter = Router();

interface SignUpBody {
    name: string;
    email: string;
    password: string;
}


interface LogInBody {
    email: string;
    password: string;
}

authRouter.post('/signup', async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    try {
        const { name, email, password } = req.body;
        const existingUser = await db.select().from(users).where(eq(users.email, email))

        if (existingUser.length) {
            res.status(400).json({ error: 'User with email $email already exists' });
            return;
        }

        const hashedPassword = await bcryptjs.hash(password, 8);
        const newUser: NewUser = {
            name,
            email,
            password: hashedPassword,
        }

        const [user] = await db.insert(users).values(newUser).returning();
        res.status(201).json(user);
    }
    catch (error) {
        res.status(500).json({ error: error });
    }
})


authRouter.post(
    '/login',
    async (req: Request<{}, {}, LogInBody>, res: Response) => {
        try {
            const { email, password } = req.body;
            const [existingUser] = await db.select().from(users).where(eq(users.email, email))

            if (!existingUser) {
                res.status(400).json({ error: `User with email ${email} doesn't exists. Plz try Registering up!` });
                return;
            }

            const isMatch = await bcryptjs.compare(password, existingUser.password);
            if (!isMatch) {
                res.status(400).json({ error: `Incorrect Password!` });
                return;
            }

            const token = jwt.sign({ id: existingUser.id }, "passwordKyeKayKey");

            res.status(200).json({ token, ...existingUser })
        }
        catch (error) {
            res.status(500).json({ error: error });
        }
    }
)

authRouter.post('/tokenIsValid', async (req, res) => {
    try {
        const token = req.header('x-auth-token')
        if (!token) {
            res.json(false)
            return;
        }

        const verified = jwt.verify(token, "passwordKyeKayKey")
        if (!verified) {
            res.json(false)
            return;
        }

        const verifiedToken = verified as { id: UUID };

        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id))
        if (!user) {
            res.json(false)
            return;
        }

        res.status(200).json(true)

    }
    catch (error) {
        res.status(500).json({ error: `Error from authRouter.post('/tokenIsValid')` });
    }
});

authRouter.get('/', auth, (req: AuthRequest, res) => {
    res.send(req.token);
})


export default authRouter;