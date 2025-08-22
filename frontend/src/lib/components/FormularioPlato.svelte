<script lang="ts">
  import { TipoComida } from '../types';
  import { api } from '../services/api';
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();
  
  let nombreEstudiante = '';
  let tipoComida: TipoComida = TipoComida.ALMUERZO;
  let cargando = false;
  let mostrarFormulario = false;

  async function crearPlato() {
    if (!nombreEstudiante.trim()) return;
    
    cargando = true;
    try {
      await api.crearPlato({
        nombreEstudiante: nombreEstudiante.trim(),
        tipoComida
      });
      
      dispatch('platoCreado');
      nombreEstudiante = '';
      mostrarFormulario = false;
    } catch (error) {
      console.error('Error al crear plato:', error);
      alert('Error al registrar el plato');
    } finally {
      cargando = false;
    }
  }

  function toggleFormulario() {
    mostrarFormulario = !mostrarFormulario;
    if (!mostrarFormulario) {
      nombreEstudiante = '';
    }
  }

  function irAPlatosDisponibles() {
    const elemento = document.getElementById('platos-disponibles');
    if (elemento) {
      elemento.scrollIntoView({ behavior: 'smooth' });
    }
  }
</script>

<div class="card mb-6">
  <div class="text-center">
    {#if !mostrarFormulario}
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <button 
          class="btn-primary text-lg"
          on:click={toggleFormulario}
        >
          ➕ No voy a comer mi plato
        </button>
        <button 
          class="btn-secondary text-lg"
          on:click={irAPlatosDisponibles}
        >
          🍴 Tomar plato disponible
        </button>
      </div>
      <p class="text-gray-600 mt-4 text-sm">
        ¿Tienes un plato que no vas a comer? ¡Regístralo! ¿Quieres un plato extra? ¡Busca uno disponible!
      </p>
    {:else}
      <div class="animate-slide-up">
        <h3 class="text-xl font-bold text-gray-800 mb-4">
          📝 Registrar plato disponible
        </h3>
        
        <form on:submit|preventDefault={crearPlato} class="space-y-4">
          <div>
            <label for="nombre-estudiante" class="block text-sm font-medium text-gray-700 mb-2 text-left">
              Tu nombre:
            </label>
            <input 
              id="nombre-estudiante"
              type="text" 
              bind:value={nombreEstudiante}
              class="input-field"
              placeholder="Escribe tu nombre"
              disabled={cargando}
              required
            />
          </div>
          
          <div>
            <label for="tipo-comida" class="block text-sm font-medium text-gray-700 mb-2 text-left">
              Tipo de comida:
            </label>
            <div class="grid grid-cols-2 gap-3">
              <button
                type="button"
                class="p-3 rounded-lg border-2 transition-all duration-300 {tipoComida === TipoComida.ALMUERZO ? 'border-yellow-400 bg-yellow-50 shadow-md scale-105' : 'border-gray-200 hover:border-yellow-300 bg-white'}"
                on:click={() => tipoComida = TipoComida.ALMUERZO}
                disabled={cargando}
              >
                <div class="text-2xl mb-1">🍽️</div>
                <div class="font-medium {tipoComida === TipoComida.ALMUERZO ? 'text-yellow-800' : 'text-gray-600'}">Almuerzo</div>
                {#if tipoComida === TipoComida.ALMUERZO}
                  <div class="text-xs text-yellow-600 mt-1">✓ Seleccionado</div>
                {/if}
              </button>
              
              <button
                type="button"
                class="p-3 rounded-lg border-2 transition-all duration-300 {tipoComida === TipoComida.CENA ? 'border-purple-400 bg-purple-50 shadow-md scale-105' : 'border-gray-200 hover:border-purple-300 bg-white'}"
                on:click={() => tipoComida = TipoComida.CENA}
                disabled={cargando}
              >
                <div class="text-2xl mb-1">🌙</div>
                <div class="font-medium {tipoComida === TipoComida.CENA ? 'text-purple-800' : 'text-gray-600'}">Cena</div>
                {#if tipoComida === TipoComida.CENA}
                  <div class="text-xs text-purple-600 mt-1">✓ Seleccionado</div>
                {/if}
              </button>
            </div>
          </div>
          
          <div class="flex space-x-3">
            <button 
              type="submit"
              class="btn-primary flex-1"
              disabled={!nombreEstudiante.trim() || cargando}
            >
              {#if cargando}
                🔄 Registrando...
              {:else}
                ✅ Registrar plato
              {/if}
            </button>
            <button 
              type="button"
              class="bg-gray-300 text-gray-700 px-4 py-2 rounded-lg font-medium hover:bg-gray-400 transition-colors"
              on:click={toggleFormulario}
              disabled={cargando}
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    {/if}
  </div>
</div>
