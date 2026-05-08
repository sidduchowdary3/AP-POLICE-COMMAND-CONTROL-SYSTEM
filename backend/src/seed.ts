import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding AP Police Community database...\n');

  // 1. Create a default station
  const station = await prisma.station.upsert({
    where: { id: 'station-ap-hq' },
    update: {},
    create: {
      id: 'station-ap-hq',
      name: 'Andhra Pradesh Police Headquarters',
      location: 'Mangalagiri, Andhra Pradesh',
    },
  });
  console.log('✅ Station created:', station.name);

  // 2. Super Admin
  const superAdmin = await prisma.user.upsert({
    where: { email: 'superadmin@ap.gov.in' },
    update: {
      password: await bcrypt.hash('Admin@123', 10),
    },
    create: {
      email: 'superadmin@ap.gov.in',
      password: await bcrypt.hash('Admin@123', 10),
      role: 'SUPER_ADMIN',
    },
  });
  console.log('✅ Super Admin created: superadmin@ap.gov.in / Admin@123');

  // 3. Command Officer
  const commandOfficer = await prisma.user.upsert({
    where: { email: 'commander@ap.gov.in' },
    update: {
      password: await bcrypt.hash('Command@123', 10),
    },
    create: {
      email: 'commander@ap.gov.in',
      password: await bcrypt.hash('Command@123', 10),
      role: 'COMMAND_OFFICER',
      stationId: station.id,
    },
  });
  console.log('✅ Command Officer created: commander@ap.gov.in / Command@123');

  // 4. Police Personnel
  const personnel = await prisma.user.upsert({
    where: { email: 'officer@ap.gov.in' },
    update: {
      password: await bcrypt.hash('Police@123', 10),
    },
    create: {
      email: 'officer@ap.gov.in',
      password: await bcrypt.hash('Police@123', 10),
      role: 'PERSONNEL',
      stationId: station.id,
    },
  });
  console.log('✅ Police Personnel created: officer@ap.gov.in / Police@123');

  console.log('\n✅ All credentials seeded successfully!\n');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
