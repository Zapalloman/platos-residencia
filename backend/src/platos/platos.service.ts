import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Plato, TipoComida } from './plato.entity';
import { CreatePlatoDto, ReclamarPlatoDto } from './plato.dto';

@Injectable()
export class PlatosService {
  constructor(
    @InjectRepository(Plato)
    private platosRepository: Repository<Plato>,
  ) {}

  async crear(createPlatoDto: CreatePlatoDto): Promise<Plato> {
    const plato = this.platosRepository.create(createPlatoDto);
    const resultado = await this.platosRepository.save(plato);
    
    // Log administrativo
    const tipoEmoji = createPlatoDto.tipoComida === TipoComida.ALMUERZO ? '🍽️' : '🌙';
    console.log(`\n📝 [REGISTRO] ${tipoEmoji} ${createPlatoDto.tipoComida.toUpperCase()}`);
    console.log(`   👤 Usuario: ${createPlatoDto.nombreEstudiante}`);
    console.log(`   🕐 Hora: ${new Date().toLocaleTimeString('es-ES')}`);
    console.log(`   🆔 ID: ${resultado.id}`);
    
    return resultado;
  }

  async obtenerDisponibles(): Promise<{ almuerzo: Plato[], cena: Plato[] }> {
    // Solo mostrar platos del día actual
    const hoy = new Date();
    const inicioDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 0, 0, 0, 0);
    const finDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 23, 59, 59, 999);

    const platosDisponibles = await this.platosRepository.find({
      where: { 
        disponible: true,
        fechaCreacion: Between(inicioDelDia, finDelDia)
      },
      order: { fechaCreacion: 'DESC' }
    });

    const resultado = {
      almuerzo: platosDisponibles.filter(p => p.tipoComida === TipoComida.ALMUERZO),
      cena: platosDisponibles.filter(p => p.tipoComida === TipoComida.CENA)
    };

    // Log administrativo (cada 10 consultas para no saturar)
    const ahora = new Date();
    if (ahora.getMinutes() % 10 === 0 && ahora.getSeconds() < 30) {
      console.log(`\n👀 [CONSULTA] ${ahora.toLocaleTimeString('es-ES')}`);
      console.log(`   🍽️ Almuerzos disponibles: ${resultado.almuerzo.length}`);
      console.log(`   🌙 Cenas disponibles: ${resultado.cena.length}`);
      if (resultado.almuerzo.length > 0) {
        console.log(`   📋 Almuerzos: ${resultado.almuerzo.map(p => p.nombreEstudiante).join(', ')}`);
      }
      if (resultado.cena.length > 0) {
        console.log(`   📋 Cenas: ${resultado.cena.map(p => p.nombreEstudiante).join(', ')}`);
      }
    }

    return resultado;
  }

  async obtenerTodos(): Promise<{ almuerzo: Plato[], cena: Plato[] }> {
    // Solo mostrar los del día actual
    const hoy = new Date();
    const inicioDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 0, 0, 0, 0);
    const finDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 23, 59, 59, 999);
    
    const platosDelDia = await this.platosRepository.find({
      where: { 
        fechaCreacion: Between(inicioDelDia, finDelDia)
      },
      order: { fechaCreacion: 'DESC' }
    });

    return {
      almuerzo: platosDelDia.filter(p => p.tipoComida === TipoComida.ALMUERZO),
      cena: platosDelDia.filter(p => p.tipoComida === TipoComida.CENA)
    };
  }

  async reclamar(id: number, reclamarPlatoDto: ReclamarPlatoDto): Promise<Plato> {
    console.log(`🔍 [DEBUG] Intentando reclamar plato ID: ${id}`);
    console.log(`🔍 [DEBUG] Datos recibidos:`, reclamarPlatoDto);
    
    const plato = await this.platosRepository.findOne({ where: { id } });
    
    if (!plato) {
      console.log(`❌ [ERROR] Plato con ID ${id} no encontrado`);
      throw new NotFoundException('Plato no encontrado');
    }

    if (!plato.disponible) {
      console.log(`❌ [ERROR] Plato ID ${id} ya fue reclamado por: ${plato.reclamadoPor}`);
      throw new NotFoundException('Este plato ya fue reclamado');
    }

    plato.disponible = false;
    plato.reclamadoPor = reclamarPlatoDto.reclamadoPor;
    plato.fechaReclamado = new Date();

    const resultado = await this.platosRepository.save(plato);
    
    // Log administrativo
    const tipoEmoji = plato.tipoComida === TipoComida.ALMUERZO ? '🍽️' : '🌙';
    console.log(`\n🍴 [RECLAMADO] ${tipoEmoji} ${plato.tipoComida.toUpperCase()}`);
    console.log(`   👤 Dueño original: ${plato.nombreEstudiante}`);
    console.log(`   🙋 Reclamado por: ${reclamarPlatoDto.reclamadoPor}`);
    console.log(`   🕐 Hora: ${new Date().toLocaleTimeString('es-ES')}`);
    console.log(`   🆔 ID: ${id}`);

    return resultado;
  }

  async eliminar(id: number): Promise<void> {
    await this.platosRepository.delete(id);
  }

  async limpiarPlatosAntiguos(): Promise<void> {
    // Eliminar platos de días anteriores (mantener solo del día actual)
    const hoy = new Date();
    const inicioDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 0, 0, 0, 0);
    
    const resultado = await this.platosRepository.delete({
      fechaCreacion: Between(new Date(0), inicioDelDia)
    });
    
    console.log(`🧹 Limpieza automática: ${resultado.affected || 0} platos antiguos eliminados`);
  }

  async obtenerEstadisticasDelDia(): Promise<{
    totalPlatos: number;
    platosDisponibles: number;
    platosReclamados: number;
    almuerzoDisponible: number;
    cenaDisponible: number;
  }> {
    const hoy = new Date();
    const inicioDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 0, 0, 0, 0);
    const finDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 23, 59, 59, 999);

    const platosDelDia = await this.platosRepository.find({
      where: { 
        fechaCreacion: Between(inicioDelDia, finDelDia)
      }
    });

    const disponibles = platosDelDia.filter(p => p.disponible);
    const reclamados = platosDelDia.filter(p => !p.disponible);

    return {
      totalPlatos: platosDelDia.length,
      platosDisponibles: disponibles.length,
      platosReclamados: reclamados.length,
      almuerzoDisponible: disponibles.filter(p => p.tipoComida === TipoComida.ALMUERZO).length,
      cenaDisponible: disponibles.filter(p => p.tipoComida === TipoComida.CENA).length,
    };
  }
}
