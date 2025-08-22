import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Habilitar CORS para acceso desde dispositivos móviles en la misma red
  app.enableCors({
    origin: true, // Permitir cualquier origen en desarrollo
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });

  await app.listen(3000, '0.0.0.0'); // Escuchar en todas las interfaces de red
  
  console.log('\n🍽️ ═══════════════════════════════════════════════════════');
  console.log('🚀 SISTEMA DE PLATOS - RESIDENCIA UNIVERSITARIA');
  console.log('🍽️ ═══════════════════════════════════════════════════════');
  console.log('🌐 Servidor funcionando en:');
  console.log('   📍 Local: http://localhost:3000');
  console.log('   📍 Red: http://[TU-IP]:3000');
  console.log('📱 Accesible desde dispositivos móviles en la misma red');
  console.log('👨‍💻 Logs administrativos: ACTIVADOS');
  console.log('🔄 Reinicio automático: 00:00 cada día');
  console.log('📊 Reportes horarios: ACTIVADOS');
  console.log('═══════════════════════════════════════════════════════\n');
  console.log('📝 Esperando actividad de usuarios...\n');
}
bootstrap();
