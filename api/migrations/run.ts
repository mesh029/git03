import fs from 'fs';
import path from 'path';
import pool from '../src/config/database';

const migrationsDir = path.join(__dirname);

interface Migration {
  name: string;
  file: string;
}

async function runMigrations() {
  try {
    // Create migrations table if it doesn't exist
    await pool.query(`
      CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) UNIQUE NOT NULL,
        executed_at TIMESTAMP DEFAULT NOW()
      )
    `);

    // Get list of migration files
    const files = fs.readdirSync(migrationsDir)
      .filter(file => file.endsWith('.sql'))
      .sort();

    console.log(`Found ${files.length} migration files`);

    // Get already executed migrations
    const result = await pool.query('SELECT name FROM migrations');
    const executedMigrations = new Set(result.rows.map((row: { name: string }) => row.name));

    // Execute pending migrations
    for (const file of files) {
      if (executedMigrations.has(file)) {
        console.log(`⏭️  Skipping ${file} (already executed)`);
        continue;
      }

      console.log(`🔄 Running migration: ${file}`);

      const migrationSQL = fs.readFileSync(
        path.join(migrationsDir, file),
        'utf-8'
      );

      // Start transaction
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        
        // Execute migration
        await client.query(migrationSQL);
        
        // Record migration
        await client.query(
          'INSERT INTO migrations (name) VALUES ($1)',
          [file]
        );
        
        await client.query('COMMIT');
        console.log(`✅ Completed migration: ${file}`);
      } catch (error) {
        await client.query('ROLLBACK');
        console.error(`❌ Failed migration: ${file}`, error);
        throw error;
      } finally {
        client.release();
      }
    }

    console.log('✨ All migrations completed successfully!');
  } catch (error) {
    console.error('Migration error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

runMigrations();
