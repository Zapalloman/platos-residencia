<script lang="ts">
  import { onMount, onDestroy } from 'svelte';

  let tiempoRestante = '';
  let porcentajeDia = 0;
  let intervalo: number;

  function calcularTiempoHastaMedianoche() {
    const ahora = new Date();
    const medianoche = new Date();
    medianoche.setHours(24, 0, 0, 0); // Próxima medianoche
    
    const diferencia = medianoche.getTime() - ahora.getTime();
    
    const horas = Math.floor(diferencia / (1000 * 60 * 60));
    const minutos = Math.floor((diferencia % (1000 * 60 * 60)) / (1000 * 60));
    
    tiempoRestante = `${horas}h ${minutos}m`;
    
    // Calcular porcentaje del día transcurrido
    const inicioDelDia = new Date();
    inicioDelDia.setHours(0, 0, 0, 0);
    const tiempoTranscurrido = ahora.getTime() - inicioDelDia.getTime();
    const tiempoTotalDelDia = 24 * 60 * 60 * 1000; // 24 horas en milisegundos
    porcentajeDia = (tiempoTranscurrido / tiempoTotalDelDia) * 100;
  }

  onMount(() => {
    calcularTiempoHastaMedianoche();
    // Actualizar cada minuto
    intervalo = setInterval(calcularTiempoHastaMedianoche, 60000);
  });

  onDestroy(() => {
    if (intervalo) {
      clearInterval(intervalo);
    }
  });
</script>

<div class="card mb-6" style="background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);">
  <div class="flex items-center justify-between">
    <div class="flex items-center space-x-3">
      <div class="text-2xl">🕛</div>
      <div>
        <h3 class="font-semibold text-gray-800">Reinicio Automático</h3>
        <p class="text-sm text-gray-600">Los platos se reinician cada día a las 00:00</p>
      </div>
    </div>
    <div class="text-right">
      <div class="text-lg font-bold text-yellow-800">{tiempoRestante}</div>
      <div class="text-xs text-yellow-600">hasta reinicio</div>
    </div>
  </div>
  
  <!-- Barra de progreso del día -->
  <div class="mt-4">
    <div class="flex justify-between text-xs text-yellow-700 mb-1">
      <span>Progreso del día</span>
      <span>{Math.round(porcentajeDia)}%</span>
    </div>
    <div class="w-full bg-yellow-200 rounded-full h-2">
      <div 
        class="bg-yellow-500 h-2 rounded-full transition-all duration-1000" 
        style="width: {porcentajeDia}%"
      ></div>
    </div>
  </div>
  
  <div class="mt-3 text-xs text-yellow-700 flex items-center space-x-2">
    <span>🔄</span>
    <span>Sistema actualizado automáticamente - Solo se muestran platos del día actual</span>
  </div>
</div>
