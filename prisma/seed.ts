import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Hash password
  const hashedPassword = await bcrypt.hash('password123', 12);

  // Create test users
  const users = await Promise.all([
    prisma.user.upsert({
      where: { email: 'john.doe@example.com' },
      update: {},
      create: {
        email: 'john.doe@example.com',
        fullName: 'John Doe',
        phoneNumber: '+1234567890',
        password: hashedPassword,
      },
    }),
    prisma.user.upsert({
      where: { email: 'rofiq@example.com' },
      update: {},
      create: {
        email: 'rofiq@example.com',
        fullName: 'Rofiq Rofiq',
        phoneNumber: '+6285731966274',
        password: hashedPassword,
      },
    }),
  ]);

  console.log('✅ Database seeded successfully');
  console.log(`Created ${users.length} users`);
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
