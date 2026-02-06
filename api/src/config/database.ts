import { Pool } from 'pg';
import dotenv from 'dotenv';
import { logError } from '../utils/logger';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

pool.on('error', (err) => {
  logError(err as Error, { context: 'database_idle_client' });
  process.exit(-1);
});

export default pool;
