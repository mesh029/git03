import pool from '../src/config/database';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';

const SALT_ROUNDS = 12; // Match production security

interface SeedUser {
  email: string;
  password: string;
  name: string;
  phone: string;
  isAdmin?: boolean;
  isAgent?: boolean;
  description?: string;
}

interface SeedProperty {
  agentId: string;
  type: 'apartment' | 'bnb';
  title: string;
  locationLatitude: number;
  locationLongitude: number;
  areaLabel: string;
  isAvailable: boolean;
  priceLabel: string;
  rating: number;
  traction: number;
  amenities: string[];
  houseRules: string[];
  images: string[];
}

interface SeedOrder {
  ownerId: string;
  type: 'cleaning' | 'laundry' | 'property_booking';
  status: 'pending' | 'assigned' | 'in_progress' | 'completed' | 'cancelled';
  locationLatitude: number;
  locationLongitude: number;
  locationLabel: string;
  details: Record<string, unknown>;
}

// Comprehensive user seed data
const users: SeedUser[] = [
  // ============================================
  // REGULAR USERS (CUSTOMERS)
  // ============================================
  {
    email: 'customer1@juax.test',
    password: 'Test123!@#',
    name: 'John Doe',
    phone: '+254712345678',
    description: 'Regular customer - Freemium user - Active',
  },
  {
    email: 'customer2@juax.test',
    password: 'Test123!@#',
    name: 'Jane Smith',
    phone: '+254712345679',
    description: 'Regular customer - Premium user - Frequent orders',
  },
  {
    email: 'customer3@juax.test',
    password: 'Test123!@#',
    name: 'Mary Wanjiku',
    phone: '+254712345680',
    description: 'Regular customer - Active user - Property bookings',
  },
  {
    email: 'freemium@juax.test',
    password: 'Test123!@#',
    name: 'Freemium User',
    phone: '+254712345681',
    description: 'Freemium tier customer - Limited access',
  },
  {
    email: 'customer4@juax.test',
    password: 'Test123!@#',
    name: 'Peter Ochieng',
    phone: '+254712345682',
    description: 'Regular customer - New user - No orders yet',
  },
  {
    email: 'customer5@juax.test',
    password: 'Test123!@#',
    name: 'Sarah Muthoni',
    phone: '+254712345683',
    description: 'Regular customer - Premium user - Multiple services',
  },
  {
    email: 'customer6@juax.test',
    password: 'Test123!@#',
    name: 'David Kipchoge',
    phone: '+254712345684',
    description: 'Regular customer - Freemium - Reached monthly limit',
  },

  // ============================================
  // AGENTS (PROPERTY OWNERS/MANAGERS)
  // ============================================
  {
    email: 'agent1@juax.test',
    password: 'Agent123!@#',
    name: 'Agent Williams',
    phone: '+254722345678',
    isAgent: true,
    description: 'Property agent - Multiple properties - High rating',
  },
  {
    email: 'agent2@juax.test',
    password: 'Agent123!@#',
    name: 'Agent Kamau',
    phone: '+254722345679',
    isAgent: true,
    description: 'Property agent - Single property - New agent',
  },
  {
    email: 'agent3@juax.test',
    password: 'Agent123!@#',
    name: 'Agent Nyawira',
    phone: '+254722345680',
    isAgent: true,
    description: 'Property agent - Multiple properties - Premium listings',
  },
  {
    email: 'agent4@juax.test',
    password: 'Agent123!@#',
    name: 'Agent Otieno',
    phone: '+254722345681',
    isAgent: true,
    description: 'Property agent - BnB specialist - Multiple locations',
  },
  {
    email: 'agent5@juax.test',
    password: 'Agent123!@#',
    name: 'Agent Wanjala',
    phone: '+254722345682',
    isAgent: true,
    description: 'Property agent - Apartment specialist - Nairobi',
  },
  {
    email: 'agent6@juax.test',
    password: 'Agent123!@#',
    name: 'Agent Chebet',
    phone: '+254722345683',
    isAgent: true,
    description: 'Property agent - New agent - No properties yet',
  },

  // ============================================
  // SERVICE PROVIDERS (Agents who also provide services)
  // ============================================
  {
    email: 'provider1@juax.test',
    password: 'Provider123!@#',
    name: 'Service Provider One',
    phone: '+254733345678',
    isAgent: true,
    description: 'Agent + Service Provider - Cleaning & Laundry - Active',
  },
  {
    email: 'provider2@juax.test',
    password: 'Provider123!@#',
    name: 'Service Provider Two',
    phone: '+254733345679',
    isAgent: true,
    description: 'Agent + Service Provider - Laundry specialist',
  },
  {
    email: 'provider3@juax.test',
    password: 'Provider123!@#',
    name: 'Cleaning Services Ltd',
    phone: '+254733345680',
    isAgent: true,
    description: 'Agent + Service Provider - Cleaning specialist - Premium',
  },
  {
    email: 'provider4@juax.test',
    password: 'Provider123!@#',
    name: 'Fresh Laundry Co',
    phone: '+254733345681',
    isAgent: true,
    description: 'Agent + Service Provider - Laundry only - High volume',
  },

  // ============================================
  // ADMINS
  // ============================================
  {
    email: 'admin@juax.test',
    password: 'Admin123!@#',
    name: 'Admin User',
    phone: '+254744345678',
    isAdmin: true,
    description: 'Platform administrator - Full access',
  },
  {
    email: 'admin2@juax.test',
    password: 'Admin123!@#',
    name: 'Super Admin',
    phone: '+254744345679',
    isAdmin: true,
    description: 'Super administrator - System management',
  },
  {
    email: 'admin3@juax.test',
    password: 'Admin123!@#',
    name: 'Support Admin',
    phone: '+254744345680',
    isAdmin: true,
    description: 'Support administrator - User management',
  },

  // ============================================
  // COMBINED ROLES
  // ============================================
  {
    email: 'superuser@juax.test',
    password: 'Super123!@#',
    name: 'Super User',
    phone: '+254755345678',
    isAdmin: true,
    isAgent: true,
    description: 'Admin + Agent - Full platform access',
  },
  {
    email: 'adminagent@juax.test',
    password: 'AdminAgent123!@#',
    name: 'Admin Agent',
    phone: '+254755345679',
    isAdmin: true,
    isAgent: true,
    description: 'Admin + Agent - Platform management + Properties',
  },
];

// Properties seed data
const properties: Omit<SeedProperty, 'agentId'>[] = [
  {
    type: 'apartment',
    title: 'Modern 2BR Apartment in Westlands',
    locationLatitude: -1.2634,
    locationLongitude: 36.8007,
    areaLabel: 'Westlands, Nairobi',
    isAvailable: true,
    priceLabel: 'KES 15,000/night',
    rating: 4.5,
    traction: 120,
    amenities: ['WiFi', 'Parking', 'Kitchen', 'AC', 'Washing Machine'],
    houseRules: ['No smoking', 'No parties', 'Check-in after 2PM'],
    images: [],
  },
  {
    type: 'bnb',
    title: 'Cozy Studio BnB in Kisumu',
    locationLatitude: -0.0917,
    locationLongitude: 34.7680,
    areaLabel: 'Milimani, Kisumu',
    isAvailable: true,
    priceLabel: 'KES 5,000/night',
    rating: 4.2,
    traction: 85,
    amenities: ['WiFi', 'Kitchen', 'Parking'],
    houseRules: ['Check-in after 2PM', 'No pets'],
    images: [],
  },
  {
    type: 'apartment',
    title: 'Luxury 3BR Apartment in Milimani',
    locationLatitude: -0.1000,
    locationLongitude: 34.7700,
    areaLabel: 'Milimani, Kisumu',
    isAvailable: true,
    priceLabel: 'KES 20,000/night',
    rating: 4.8,
    traction: 200,
    amenities: ['WiFi', 'Parking', 'Kitchen', 'AC', 'Swimming Pool', 'Gym'],
    houseRules: ['No smoking', 'No parties', 'Quiet hours 10PM-7AM'],
    images: [],
  },
  {
    type: 'bnb',
    title: 'Budget-Friendly Studio in Nyalenda',
    locationLatitude: -0.1200,
    locationLongitude: 34.7500,
    areaLabel: 'Nyalenda, Kisumu',
    isAvailable: true,
    priceLabel: 'KES 3,000/night',
    rating: 3.8,
    traction: 45,
    amenities: ['WiFi', 'Kitchen'],
    houseRules: ['Standard rules'],
    images: [],
  },
  {
    type: 'apartment',
    title: 'Temporarily Unavailable Apartment',
    locationLatitude: -1.2921,
    locationLongitude: 36.8219,
    areaLabel: 'CBD, Nairobi',
    isAvailable: false,
    priceLabel: 'KES 10,000/night',
    rating: 4.0,
    traction: 50,
    amenities: ['WiFi', 'Parking'],
    houseRules: ['Standard rules'],
    images: [],
  },
  {
    type: 'bnb',
    title: 'Luxury BnB in Karen',
    locationLatitude: -1.3193,
    locationLongitude: 36.7010,
    areaLabel: 'Karen, Nairobi',
    isAvailable: true,
    priceLabel: 'KES 25,000/night',
    rating: 4.9,
    traction: 300,
    amenities: ['WiFi', 'Parking', 'Kitchen', 'AC', 'Swimming Pool', 'Gym', 'Garden'],
    houseRules: ['No smoking', 'No parties', 'Pets allowed'],
    images: [],
  },
  {
    type: 'apartment',
    title: 'Affordable 1BR in Kilimani',
    locationLatitude: -1.2833,
    locationLongitude: 36.7833,
    areaLabel: 'Kilimani, Nairobi',
    isAvailable: true,
    priceLabel: 'KES 8,000/night',
    rating: 4.3,
    traction: 95,
    amenities: ['WiFi', 'Parking', 'Kitchen'],
    houseRules: ['No smoking', 'Check-in after 2PM'],
    images: [],
  },
  {
    type: 'bnb',
    title: 'Beachfront BnB in Mombasa',
    locationLatitude: -4.0435,
    locationLongitude: 39.6682,
    areaLabel: 'Nyali, Mombasa',
    isAvailable: true,
    priceLabel: 'KES 18,000/night',
    rating: 4.7,
    traction: 250,
    amenities: ['WiFi', 'Parking', 'Kitchen', 'AC', 'Beach Access'],
    houseRules: ['No smoking', 'No parties', 'Beach rules apply'],
    images: [],
  },
];

// Orders seed data
const orders: SeedOrder[] = [
  {
    ownerId: '', // Will be set to customer1
    type: 'cleaning',
    status: 'pending',
    locationLatitude: -0.0917,
    locationLongitude: 34.7680,
    locationLabel: 'Milimani, Kisumu',
    details: {
      service: 'deepCleaning',
      rooms: 3,
    },
  },
  {
    ownerId: '', // Will be set to customer2
    type: 'laundry',
    status: 'assigned',
    locationLatitude: -0.0917,
    locationLongitude: 34.7680,
    locationLabel: 'Milimani, Kisumu',
    details: {
      serviceType: 'washAndFold',
      quantity: 5,
      items: ['shirts', 'pants', 'towels'],
    },
  },
  {
    ownerId: '', // Will be set to customer1
    type: 'laundry',
    status: 'in_progress',
    locationLatitude: -0.1000,
    locationLongitude: 34.7700,
    locationLabel: 'Milimani, Kisumu',
    details: {
      serviceType: 'dryClean',
      quantity: 3,
      items: ['suit', 'dress', 'jacket'],
    },
  },
  {
    ownerId: '', // Will be set to customer2
    type: 'cleaning',
    status: 'completed',
    locationLatitude: -1.2634,
    locationLongitude: 36.8007,
    locationLabel: 'Westlands, Nairobi',
    details: {
      service: 'regularCleaning',
      rooms: 2,
    },
  },
];

async function seedDatabase(): Promise<void> {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    console.log('🌱 Seeding database with comprehensive test data...\n');

    // Clear existing test data (in reverse order of dependencies)
    console.log('📋 Clearing existing test data...');
    await client.query('DELETE FROM messages');
    await client.query('DELETE FROM conversation_participants');
    await client.query('DELETE FROM conversations');
    await client.query('DELETE FROM subscription_features');
    await client.query('DELETE FROM subscriptions');
    await client.query('DELETE FROM order_status_history');
    await client.query('DELETE FROM order_tracking');
    await client.query('DELETE FROM property_bookings');
    await client.query('DELETE FROM orders');
    await client.query('DELETE FROM properties');
    await client.query('DELETE FROM users WHERE email LIKE $1', ['%@juax.test']);
    console.log('  ✓ Cleared existing test data\n');

    // Seed users
    console.log('👥 Seeding users...');
    const userIds: Record<string, string> = {};

    for (const user of users) {
      const passwordHash = await bcrypt.hash(user.password, SALT_ROUNDS);
      const userId = uuidv4();

      await client.query(
        `INSERT INTO users (id, email, password_hash, name, phone, is_admin, is_agent, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())`,
        [
          userId,
          user.email.toLowerCase(),
          passwordHash,
          user.name,
          user.phone,
          user.isAdmin || false,
          user.isAgent || false,
        ]
      );

      userIds[user.email] = userId;
      const roles = [];
      if (user.isAdmin) roles.push('Admin');
      if (user.isAgent) roles.push('Agent');
      if (roles.length === 0) roles.push('Customer');
      console.log(`  ✓ ${user.email.padEnd(25)} | ${user.name.padEnd(20)} | ${roles.join(' + ')}`);
    }

    console.log(`\n  📊 Created ${users.length} users\n`);

    // Seed properties
    console.log('🏠 Seeding properties...');
    const agentIds = [
      userIds['agent1@juax.test'],
      userIds['agent2@juax.test'],
      userIds['agent3@juax.test'],
      userIds['agent4@juax.test'],
      userIds['agent5@juax.test'],
      userIds['provider1@juax.test'],
      userIds['provider2@juax.test'],
      userIds['superuser@juax.test'],
    ];
    const propertyIds: string[] = [];

    properties.forEach((property, index) => {
      const agentId = agentIds[index % agentIds.length];
      const propertyId = uuidv4();

      client.query(
        `INSERT INTO properties (
          id, agent_id, type, title, location_latitude, location_longitude,
          area_label, is_available, price_label, rating, traction,
          amenities, house_rules, images, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, NOW(), NOW())`,
        [
          propertyId,
          agentId,
          property.type,
          property.title,
          property.locationLatitude,
          property.locationLongitude,
          property.areaLabel,
          property.isAvailable,
          property.priceLabel,
          property.rating,
          property.traction,
          property.amenities,
          property.houseRules,
          property.images,
        ]
      );

      propertyIds.push(propertyId);
      console.log(`  ✓ ${property.title} (${property.isAvailable ? 'Available' : 'Unavailable'})`);
    });

    console.log(`\n  📊 Created ${properties.length} properties\n`);

    // Seed orders
    console.log('📦 Seeding orders...');
    const orderIds: string[] = [];

    // Set order owners
    orders[0].ownerId = userIds['customer1@juax.test'];
    orders[1].ownerId = userIds['customer2@juax.test'];
    orders[2].ownerId = userIds['customer1@juax.test'];
    orders[3].ownerId = userIds['customer2@juax.test'];

    for (const order of orders) {
      const orderId = uuidv4();

      await client.query(
        `INSERT INTO orders (
          id, owner_id, type, status, location_latitude, location_longitude,
          location_label, details, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())`,
        [
          orderId,
          order.ownerId,
          order.type,
          order.status,
          order.locationLatitude,
          order.locationLongitude,
          order.locationLabel,
          JSON.stringify(order.details),
        ]
      );

      orderIds.push(orderId);
      console.log(`  ✓ ${order.type} order - ${order.status} (${order.locationLabel})`);
    }

    console.log(`\n  📊 Created ${orders.length} orders\n`);

    await client.query('COMMIT');

    // Print summary
    console.log('\n' + '='.repeat(80));
    console.log('✅ Database seeded successfully!');
    console.log('='.repeat(80));

    console.log('\n📋 Test Users Credentials:');
    console.log('-'.repeat(80));
    users.forEach((user) => {
      const roles = [];
      if (user.isAdmin) roles.push('Admin');
      if (user.isAgent) roles.push('Agent');
      if (roles.length === 0) roles.push('Customer');
      console.log(`  Email: ${user.email.padEnd(25)} | Password: ${user.password.padEnd(15)} | Role: ${roles.join(' + ')}`);
    });

    console.log('\n🏠 Properties Summary:');
    console.log('-'.repeat(80));
    properties.forEach((prop, index) => {
      console.log(`  ${index + 1}. ${prop.title}`);
      console.log(`     Location: ${prop.areaLabel} | Price: ${prop.priceLabel} | ${prop.isAvailable ? '✅ Available' : '❌ Unavailable'}`);
    });

    console.log('\n📦 Orders Summary:');
    console.log('-'.repeat(80));
    orders.forEach((order, index) => {
      console.log(`  ${index + 1}. ${order.type.toUpperCase()} - ${order.status} | ${order.locationLabel}`);
    });

    console.log('\n💡 Quick Test Commands:');
    console.log('-'.repeat(80));
    console.log('  # Login as customer');
    console.log(`  curl -X POST http://localhost:3000/v1/auth/login \\`);
    console.log(`    -H "Content-Type: application/json" \\`);
    console.log(`    -d '{"email":"customer1@juax.test","password":"Test123!@#"}'`);
    console.log('\n  # Login as agent');
    console.log(`  curl -X POST http://localhost:3000/v1/auth/login \\`);
    console.log(`    -H "Content-Type: application/json" \\`);
    console.log(`    -d '{"email":"agent1@juax.test","password":"Agent123!@#"}'`);
    console.log('\n  # Login as admin');
    console.log(`  curl -X POST http://localhost:3000/v1/auth/login \\`);
    console.log(`    -H "Content-Type: application/json" \\`);
    console.log(`    -d '{"email":"admin@juax.test","password":"Admin123!@#"}'`);

    console.log('\n' + '='.repeat(80));
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('\n❌ Error seeding database:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Run seed
seedDatabase()
  .then(() => {
    console.log('\n✨ Seed completed successfully!\n');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Seed failed:', error);
    process.exit(1);
  });
