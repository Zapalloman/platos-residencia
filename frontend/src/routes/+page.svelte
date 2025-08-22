<script lang="ts">
  import { onMount } from 'svelte';
  import type { PlatosResponse } from '$lib/types';
  import { api } from '$lib/services/api';
  import FormularioPlato from '$lib/components/FormularioPlato.svelte';
  import PlatoCard from '$lib/components/PlatoCard.svelte';
  import InfoReinicio from '$lib/components/InfoReinicio.svelte';
  import FechaActual from '$lib/components/FechaActual.svelte';

  let platos: PlatosResponse = { almuerzo: [], cena: [] };
  let cargando = true;
  let error = '';

  onMount(async () => {
    await cargarPlatos();
  });

  async function cargarPlatos() {
    try {
      cargando = true;
      error = '';
      platos = await api.obtenerPlatosDisponibles();
    } catch (err) {
      error = 'Error al cargar los platos. ¿Está el servidor funcionando?';
      console.error('Error:', err);
    } finally {
      cargando = false;
    }
  }

  function handlePlatoCreado() {
    cargarPlatos();
  }

  function handlePlatoReclamado() {
    cargarPlatos();
  }

  $: totalDisponibles = platos.almuerzo.length + platos.cena.length;
</script>

<svelte:head>
  <title>Platos Disponibles - Residencia</title>
  <meta name="description" content="Sistema de gestión de platos sobrantes" />
</svelte:head>

<div class="min-h-screen py-8">
  <div class="container mx-auto px-4 max-w-4xl">
    <!-- Header -->
    <header class="text-center mb-8 animate-fade-in">
      <h1 class="text-4xl font-bold text-gray-800 mb-2">
        🍽️ Platos Disponibles
      </h1>
      <p class="text-gray-600 text-lg mb-3">
        Residencia Universitaria - Sistema de Platos Sobrantes
      </p>
      
      <!-- Fecha actual compacta -->
      <div class="flex justify-center mb-4">
        <FechaActual />
      </div>
      
      {#if !cargando}
        <div class="mt-4 p-3 bg-blue-100 rounded-lg inline-block">
          <span class="text-blue-800 font-semibold">
            {totalDisponibles} platos disponibles ahora
          </span>
        </div>
      {/if}
    </header>

    <!-- Formulario para registrar plato -->
    <FormularioPlato on:platoCreado={handlePlatoCreado} />

    <!-- Error state -->
    {#if error}
      <div class="card bg-red-50 border-red-200 border text-center animate-slide-up">
        <div class="text-red-600">
          <div class="text-2xl mb-2">⚠️</div>
          <p class="font-medium">{error}</p>
          <button 
            class="mt-3 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            on:click={cargarPlatos}
          >
            Reintentar
          </button>
        </div>
      </div>
    {/if}

    <!-- Loading state -->
    {#if cargando}
      <div class="text-center py-12 animate-fade-in">
        <div class="text-4xl mb-4">🔄</div>
        <p class="text-gray-600">Cargando platos disponibles...</p>
      </div>
    {/if}

    <!-- Platos content -->
    {#if !cargando && !error}
      <div id="platos-disponibles" class="space-y-8">
        <!-- Almuerzo Section -->
        <section>
          <div class="flex items-center mb-4">
            <span class="text-3xl mr-3">🍽️</span>
            <h2 class="text-2xl font-bold text-gray-800">Almuerzo</h2>
            <span class="ml-auto bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full text-sm font-medium">
              {platos.almuerzo.length} disponibles
            </span>
          </div>
          
          {#if platos.almuerzo.length === 0}
            <div class="card text-center text-gray-500">
              <div class="text-4xl mb-2">🤷‍♀️</div>
              <p>No hay almuerzos disponibles por el momento</p>
            </div>
          {:else}
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {#each platos.almuerzo as plato (plato.id)}
                <PlatoCard {plato} on:platoReclamado={handlePlatoReclamado} />
              {/each}
            </div>
          {/if}
        </section>

        <!-- Cena Section -->
        <section>
          <div class="flex items-center mb-4">
            <span class="text-3xl mr-3">🌙</span>
            <h2 class="text-2xl font-bold text-gray-800">Cena</h2>
            <span class="ml-auto bg-purple-100 text-purple-800 px-3 py-1 rounded-full text-sm font-medium">
              {platos.cena.length} disponibles
            </span>
          </div>
          
          {#if platos.cena.length === 0}
            <div class="card text-center text-gray-500">
              <div class="text-4xl mb-2">🌜</div>
              <p>No hay cenas disponibles por el momento</p>
            </div>
          {:else}
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {#each platos.cena as plato (plato.id)}
                <PlatoCard {plato} on:platoReclamado={handlePlatoReclamado} />
              {/each}
            </div>
          {/if}
        </section>
      </div>

      <!-- Refresh button -->
      <div class="text-center mt-8">
        <button 
          class="bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors"
          on:click={cargarPlatos}
        >
          🔄 Actualizar
        </button>
      </div>
    {/if}

    <!-- Footer -->
    <footer class="text-center mt-12 text-gray-500 text-sm">
      <p> Hecho por Javier aaaaaaaa</p>
    </footer>

    <!-- Información del reinicio automático -->
    <InfoReinicio />
  </div>
</div>
