<script lang="ts">
  import { onMount } from 'svelte';
  
  let fechaActual = '';

  function actualizarFecha() {
    const hoy = new Date();
    
    // Formatear la fecha en español
    const opciones: Intl.DateTimeFormatOptions = {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    };
    
    fechaActual = hoy.toLocaleDateString('es-ES', opciones);
  }

  onMount(() => {
    actualizarFecha();
  });

  function formatearFecha(fecha: string) {
    // Capitalizar la primera letra
    return fecha.charAt(0).toUpperCase() + fecha.slice(1);
  }

  function esFinDeSemana() {
    const hoy = new Date();
    const dia = hoy.getDay();
    return dia === 0 || dia === 6; // Domingo (0) o Sábado (6)
  }
</script>

<div class="inline-block mb-4 px-4 py-2 rounded-lg" style="background: linear-gradient(135deg, #e0f2fe 0%, #b3e5fc 100%);">
  <div class="flex items-center space-x-2">
    <span class="text-lg">
      {#if esFinDeSemana()}
        🎉
      {:else}
        📅
      {/if}
    </span>
    <span class="font-semibold text-blue-800">
      {formatearFecha(fechaActual)}
    </span>
  </div>
</div>
