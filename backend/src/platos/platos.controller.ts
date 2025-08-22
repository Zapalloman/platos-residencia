import { Controller, Get, Post, Body, Param, Patch, Delete, ValidationPipe } from '@nestjs/common';
import { PlatosService } from './platos.service';
import { CreatePlatoDto, ReclamarPlatoDto } from './plato.dto';

@Controller('platos')
export class PlatosController {
  constructor(private readonly platosService: PlatosService) {}

  @Post()
  async crear(@Body(ValidationPipe) createPlatoDto: CreatePlatoDto) {
    return await this.platosService.crear(createPlatoDto);
  }

  @Get('disponibles')
  async obtenerDisponibles() {
    return await this.platosService.obtenerDisponibles();
  }

  @Get()
  async obtenerTodos() {
    return await this.platosService.obtenerTodos();
  }

  @Get('estadisticas')
  async obtenerEstadisticas() {
    return await this.platosService.obtenerEstadisticasDelDia();
  }

  @Patch(':id/reclamar')
  async reclamar(
    @Param('id') id: string,
    @Body(ValidationPipe) reclamarPlatoDto: ReclamarPlatoDto
  ) {
    return await this.platosService.reclamar(+id, reclamarPlatoDto);
  }

  @Delete(':id')
  async eliminar(@Param('id') id: string) {
    return await this.platosService.eliminar(+id);
  }
}
