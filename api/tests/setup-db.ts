import { Pool } from 'pg';

const ADMIN_DATABASE_URL = process.env.DATABASE_URL || 'postgresql://juax:juax_dev@localhost:5432/postgres';
const TEST_DATABASE_NAME = 'juax_test';

async function createTestDatabase() {
  const adminPool = new Pool({
    connectionString: ADMIN_DATABASE_URL,
  });

  try {
    // Check if database exists
    const result = await adminPool.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`,
      [TEST_DATABASE_NAME]
    );

    if (result.rows.length > 0) {
      console.log(`✅ Database "${TEST_DATABASE_NAME}" already exists`);
      await adminPool.end();
      return;
    }

    // Create database
    await adminPool.query(`CREATE DATABASE ${TEST_DATABASE_NAME}`);
    console.log(`✅ Created test database "${TEST_DATABASE_NAME}"`);
  } catch (error: any) {
    if (error.code === '3D000' || error.message.includes('does not exist')) {
      // Try connecting to default postgres database
      const postgresPool = new Pool({
        connectionString: ADMIN_DATABASE_URL.replace(/\/[^\/]+$/, '/postgres'),
      });
      try {
        await postgresPool.query(`CREATE DATABASE ${TEST_DATABASE_NAME}`);
        console.log(`✅ Created test database "${TEST_DATABASE_NAME}"`);
      } catch (err: any) {
        console.error('❌ Failed to create test database:', err.message);
        throw err;
      } finally {
        await postgresPool.end();
      }
    } else {
      console.error('❌ Failed to create test database:', error.message);
      throw error;
    }
  } finally {
    await adminPool.end();
  }
}

createTestDatabase()
  .then(() => {
    console.log('✅ Test database setup complete');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Test database setup failed:', error);
    process.exit(1);
  });
