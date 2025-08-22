<script lang="ts">
  import type { Plato } from '../types';
  import { api } from '../services/api';
  import { createEventDispatcher } from 'svelte';

  export let plato: Plato;
  
  const dispatch = createEventDispatcher();
  let reclamandoPor = '';
  let mostrarModal = false;
  let cargando = false;

  function abrirModal() {
    mostrarModal = true;
  }

  function cerrarModal() {
    mostrarModal = false;
    reclamandoPor = '';
  }

  async function reclamarPlato() {
    if (!reclamandoPor.trim()) return;
    
    cargando = true;
    try {
      await api.reclamarPlato(plato.id, reclamandoPor.trim());
      dispatch('platoReclamado');
      cerrarModal();
    } catch (error) {
      console.error('Error al reclamar plato:', error);
      alert(`Error al reclamar el plato: ${error.message}`);
    } finally {
      cargando = false;
    }
  }

  function getTipoIcon(tipo: string) {
    return tipo === 'almuerzo' ? '🍽️' : '🌙';
  }

  function getTipoColor(tipo: string) {
    return tipo === 'almuerzo' ? 'yellow' : 'purple';
  }
</script>

<div class="plate-card {plato.tipoComida} animate-slide-up">
  <div class="flex items-center justify-between mb-3">
    <div class="flex items-center space-x-2">
      <span class="text-2xl">{getTipoIcon(plato.tipoComida)}</span>
      <div>
        <h3 class="font-semibold text-gray-800">{plato.nombreEstudiante}</h3>
        <p class="text-sm text-gray-500 capitalize">{plato.tipoComida}</p>
      </div>
    </div>
    
    {#if plato.disponible}
      <button 
        class="btn-reclaim text-sm animate-bounce-subtle"
        on:click={abrirModal}
      >
        🍴 Reclamar
      </button>
    {:else}
      <div class="text-right">
        <span class="text-xs text-red-500 font-medium">Reclamado</span>
        <p class="text-xs text-gray-600">por {plato.reclamadoPor}</p>
      </div>
    {/if}
  </div>
  
  <div class="text-xs text-gray-400">
    Registrado: {new Date(plato.fechaCreacion).toLocaleTimeString('es-ES', { 
      hour: '2-digit', 
      minute: '2-digit' 
    })}
  </div>
</div>

<!-- Modal para reclamar plato -->
{#if mostrarModal}
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
    <div class="bg-white rounded-xl p-6 w-full max-w-md mx-4 animate-slide-up">
      <h3 class="text-xl font-bold text-gray-800 mb-4">
        🍴 Reclamar plato de {plato.nombreEstudiante}
      </h3>
      
      <div class="mb-4">
        <label for="reclamado-por" class="block text-sm font-medium text-gray-700 mb-2">
          Tu nombre:
        </label>
        <input 
          id="reclamado-por"
          type="text" 
          bind:value={reclamandoPor}
          class="input-field"
          placeholder="Escribe tu nombre"
          disabled={cargando}
        />
      </div>
      
      <div class="flex space-x-3">
        <button 
          class="btn-reclaim flex-1"
          on:click={reclamarPlato}
          disabled={!reclamandoPor.trim() || cargando}
        >
          {#if cargando}
            🔄 Reclamando...
          {:else}
            ✅ Confirmar
          {/if}
        </button>
        <button 
          class="bg-gray-300 text-gray-700 px-4 py-2 rounded-lg font-medium hover:bg-gray-400 transition-colors"
          on:click={cerrarModal}
          disabled={cargando}
        >
          Cancelar
        </button>
      </div>
    </div>
  </div>
{/if}
