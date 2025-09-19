import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Create sample users
  const users = [
    {
      email: 'john.doe@example.com',
      phone_number: '+1234567890',
      full_name: 'John Doe',
      password: 'password123',
    },
    {
      email: 'jane.smith@example.com',
      phone_number: '+1234567891',
      full_name: 'Jane Smith',
      password: 'password123',
    },
    {
      email: 'admin@example.com',
      phone_number: '+1234567892',
      full_name: 'Admin User',
      password: 'admin123',
    },
  ];

  for (const userData of users) {
    const { full_name, phone_number, email, password } = userData;

    // Check if user already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ email }, { phone_number }]
      }
    });

    if (existingUser) {
      console.log(`👤 User with email ${email} already exists, skipping...`);
      continue;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user with details
    const user = await prisma.user.create({
      data: {
        email,
        phone_number,
        password: hashedPassword,
        userDetails: {
          create: {
            full_name,
          },
        },
      },
      include: {
        userDetails: true,
      },
    });

    console.log(`✅ Created user: ${user.email} (${user.userDetails?.full_name})`);
  }

  console.log('🎉 Database seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
