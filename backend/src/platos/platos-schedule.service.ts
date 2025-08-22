import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PlatosService } from './platos.service';

@Injectable()
export class PlatosScheduleService {
  constructor(private readonly platosService: PlatosService) {}

  // Ejecutar limpieza automática todos los días a las 00:00
  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async limpiezaAutomatica() {
    console.log('\n🕛 ═══════════════════════════════════════════════════════');
    console.log('🔄 REINICIO AUTOMÁTICO - NUEVO DÍA INICIADO');
    console.log('🕛 ═══════════════════════════════════════════════════════');
    await this.platosService.limpiarPlatosAntiguos();
    
    const stats = await this.platosService.obtenerEstadisticasDelDia();
    console.log('📊 Sistema reseteado - Estadísticas:', stats);
    console.log('✨ ¡Listo para un nuevo día de platos! 🍽️\n');
  }

  // Mostrar estadísticas cada hora con más detalle
  @Cron(CronExpression.EVERY_HOUR)
  async mostrarEstadisticas() {
    const stats = await this.platosService.obtenerEstadisticasDelDia();
    const ahora = new Date();
    
    console.log('\n📊 ═══ RESUMEN HORARIO ═══');
    console.log(`🕐 Hora: ${ahora.toLocaleTimeString('es-ES')}`);
    console.log(`📈 Total platos registrados hoy: ${stats.totalPlatos}`);
    console.log(`✅ Disponibles: ${stats.platosDisponibles}`);
    console.log(`🍴 Reclamados: ${stats.platosReclamados}`);
    console.log(`🍽️ Almuerzos disponibles: ${stats.almuerzoDisponible}`);
    console.log(`🌙 Cenas disponibles: ${stats.cenaDisponible}`);
    
    // Mostrar actividad del día
    if (stats.totalPlatos > 0) {
      const porcentajeReclamado = Math.round((stats.platosReclamados / stats.totalPlatos) * 100);
      console.log(`📊 Tasa de reclamo: ${porcentajeReclamado}%`);
    }
    console.log('════════════════════════════\n');
  }
}
