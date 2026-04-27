import { createClient } from '@libsql/client';
import { drizzle } from 'drizzle-orm/libsql';
import * as schema from './schema.js';

export const sqliteClient = createClient();

export const db = drizzle(sqliteClient, { schema });
