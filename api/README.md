# JuaX API - Node.js Express Implementation

## Tech Stack

- **Runtime**: Node.js 20+
- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: PostgreSQL 15
- **Cache**: Redis 7
- **Authentication**: JWT (jsonwebtoken)
- **Validation**: Joi
- **Security**: Helmet, CORS, Rate Limiting
- **Testing**: Jest
- **Process Manager**: PM2 (production)

## Project Structure

```
api/
├── src/
│   ├── config/          # Configuration files
│   ├── controllers/     # Request handlers
│   ├── services/        # Business logic
│   ├── models/          # Data models
│   ├── middleware/      # Auth, validation, error handling
│   ├── routes/          # API route definitions
│   ├── utils/           # Helper functions
│   ├── validators/      # Request validation schemas
│   └── index.ts         # Application entry point
├── tests/
├── migrations/          # Database migrations
├── docker/
├── docs/               # API documentation
├── .env.example
├── docker-compose.yml
├── package.json
├── tsconfig.json
└── README.md
```

## Getting Started

### Prerequisites

- Node.js 20+ installed
- Docker and Docker Compose installed
- npm or yarn package manager

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start database and Redis:**
   ```bash
   docker-compose up -d
   ```

4. **Run database migrations:**
   ```bash
   npm run migrate
   ```

5. **Start development server:**
   ```bash
   npm run dev
   ```

The API will be available at `http://localhost:3000`

### Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm test` - Run tests
- `npm run test:watch` - Run tests in watch mode
- `npm run test:coverage` - Generate test coverage report
- `npm run lint` - Lint code
- `npm run lint:fix` - Fix linting issues
- `npm run migrate` - Run database migrations

## Development

### Environment Variables

See `.env.example` for all required environment variables.

### Database Setup

The project uses PostgreSQL. Run migrations to set up the database schema:

```bash
npm run migrate
```

### Testing

Run tests with:
```bash
npm test
```

## Production Deployment

See the main README.md for DigitalOcean deployment instructions.

## API Documentation

API documentation will be available at `/api-docs` once Swagger is configured.
