import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Create sample users
  const users = [
    {
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      fullName: 'John Doe',
      password: 'password123',
    },
    {
      email: 'jane.smith@example.com', 
      phoneNumber: '+1234567891',
      fullName: 'Jane Smith',
      password: 'password123',
    },
    {
      email: 'admin@example.com',
      phoneNumber: '+1234567892', 
      fullName: 'Admin User',
      password: 'admin123',
    },
  ];

  for (const userData of users) {
    const { fullName, phoneNumber, email, password } = userData;
    
    // Check if user already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ email }, { phoneNumber }]
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
        phoneNumber,
        password: hashedPassword,
        userDetails: {
          create: {
            fullName,
          },
        },
      },
      include: {
        userDetails: true,
      },
    });

    console.log(`✅ Created user: ${user.email} (${user.userDetails?.fullName})`);
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