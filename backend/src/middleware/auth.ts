import { UUID } from "crypto";
import { NextFunction, Request, Response } from "express";
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";
import jwt from "jsonwebtoken";

export interface AuthRequest extends Request {
    user?: UUID;
    token?: string;
}

export const auth = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const token = req.header('x-auth-token')
        if (!token) {
            res.status(401).json({ error: 'No Auth Token, access Denied! This warning is from auth.ts\middleware' });
            return;
        }

        const verified = jwt.verify(token, "passwordKyeKayKey")
        if (!verified) {
            res.status(401).json({ error: 'Token Verification Failed! This warning is from auth.ts\middleware' });
            return;
        }

        const verifiedToken = verified as { id: UUID };

        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id))
        if (!user) {
            res.status(401).json({ error: `User doesn't exists! This warning is from auth.ts\middleware` })
            return;
        }

        req.user = verifiedToken.id;
        req.token = token;
        next();
    }
    catch (error) {
        res.status(500).json({ error });
    }
}