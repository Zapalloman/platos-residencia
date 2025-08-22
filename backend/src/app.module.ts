import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { PlatosModule } from './platos/platos.module';
import { Plato } from './platos/plato.entity';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'platos.db',
      entities: [Plato],
      synchronize: true, // Solo para desarrollo
    }),
    PlatosModule,
  ],
})
export class AppModule {}
