import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlatosController } from './platos.controller';
import { PlatosService } from './platos.service';
import { PlatosScheduleService } from './platos-schedule.service';
import { Plato } from './plato.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Plato])],
  controllers: [PlatosController],
  providers: [PlatosService, PlatosScheduleService],
})
export class PlatosModule {}
