<script lang="ts">
  import { onMount } from 'svelte';
  import { api } from '$lib/services/api';

  interface LogEntry {
    id: number;
    accion: string;
    estudiante: string;
    tipoComida: string;
    hora: string;
    platoOriginal?: string;
  }

  interface LogsData {
    fecha: string;
    totalEventos: number;
    logs: LogEntry[];
  }

  let logsData: LogsData | null = null;
  let mostrarLogs = false;
  let cargando = false;
  let error = '';

  async function cargarLogs() {
    try {
      cargando = true;
      error = '';
      logsData = await api.obtenerLogsAdmin();
    } catch (err) {
      error = 'Error al cargar los logs administrativos';
      console.error(err);
    } finally {
      cargando = false;
    }
  }

  function toggleLogs() {
    mostrarLogs = !mostrarLogs;
    if (mostrarLogs && !logsData) {
      cargarLogs();
    }
  }

  function getEmojiAccion(accion: string): string {
    return accion === 'registro' ? '📝' : '🍽️';
  }

  function getEmojiComida(tipoComida: string): string {
    return tipoComida === 'almuerzo' ? '🥗' : '🌙';
  }
</script>

<div class="logs-admin-container">
  <button 
    class="toggle-logs-btn" 
    on:click={toggleLogs}
    aria-label="Toggle administrative logs"
  >
    👨‍💻 Logs Administrativos
    <span class="toggle-icon" class:rotated={mostrarLogs}>▼</span>
  </button>

  {#if mostrarLogs}
    <div class="logs-panel">
      {#if cargando}
        <div class="loading">
          <div class="spinner"></div>
          <p>Cargando logs...</p>
        </div>
      {:else if error}
        <div class="error">
          <p>❌ {error}</p>
          <button class="retry-btn" on:click={cargarLogs}>Reintentar</button>
        </div>
      {:else if logsData}
        <div class="logs-header">
          <h3>📊 Actividad del {logsData.fecha}</h3>
          <p class="total-eventos">Total de eventos: <strong>{logsData.totalEventos}</strong></p>
          <button class="refresh-btn" on:click={cargarLogs}>🔄 Actualizar</button>
        </div>

        {#if logsData.logs.length === 0}
          <div class="no-logs">
            <p>📝 No hay actividad registrada para hoy</p>
          </div>
        {:else}
          <div class="logs-list">
            {#each logsData.logs as log}
              <div class="log-entry" class:registro={log.accion === 'registro'} class:reclamo={log.accion === 'reclamo'}>
                <div class="log-icon">
                  {getEmojiAccion(log.accion)}
                  {getEmojiComida(log.tipoComida)}
                </div>
                <div class="log-content">
                  <div class="log-main">
                    <strong>{log.estudiante}</strong>
                    {#if log.accion === 'registro'}
                      registró {log.tipoComida}
                    {:else}
                      reclamó {log.tipoComida} de <em>{log.platoOriginal}</em>
                    {/if}
                  </div>
                  <div class="log-time">
                    🕐 {log.hora}
                  </div>
                </div>
              </div>
            {/each}
          </div>
        {/if}
      {/if}
    </div>
  {/if}
</div>

<style>
  .logs-admin-container {
    width: 100%;
    max-width: 600px;
    margin: 20px auto;
  }

  .toggle-logs-btn {
    width: 100%;
    padding: 12px 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: space-between;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
  }

  .toggle-logs-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
  }

  .toggle-icon {
    transition: transform 0.3s ease;
  }

  .toggle-icon.rotated {
    transform: rotate(180deg);
  }

  .logs-panel {
    background: white;
    border-radius: 8px;
    margin-top: 10px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    overflow: hidden;
  }

  .logs-header {
    background: #f8f9fa;
    padding: 15px 20px;
    border-bottom: 1px solid #e9ecef;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
  }

  .logs-header h3 {
    margin: 0;
    color: #495057;
    font-size: 18px;
  }

  .total-eventos {
    margin: 5px 0 0 0;
    color: #6c757d;
    font-size: 14px;
  }

  .refresh-btn {
    padding: 6px 12px;
    background: #28a745;
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 12px;
    cursor: pointer;
    transition: background 0.3s ease;
  }

  .refresh-btn:hover {
    background: #218838;
  }

  .loading {
    text-align: center;
    padding: 40px 20px;
    color: #6c757d;
  }

  .spinner {
    border: 3px solid #f3f3f3;
    border-top: 3px solid #667eea;
    border-radius: 50%;
    width: 30px;
    height: 30px;
    animation: spin 1s linear infinite;
    margin: 0 auto 15px;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .error {
    text-align: center;
    padding: 20px;
    color: #dc3545;
  }

  .retry-btn {
    padding: 8px 16px;
    background: #dc3545;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    margin-top: 10px;
  }

  .retry-btn:hover {
    background: #c82333;
  }

  .no-logs {
    text-align: center;
    padding: 40px 20px;
    color: #6c757d;
  }

  .logs-list {
    max-height: 400px;
    overflow-y: auto;
  }

  .log-entry {
    display: flex;
    align-items: center;
    padding: 12px 20px;
    border-bottom: 1px solid #f1f3f4;
    transition: background 0.2s ease;
  }

  .log-entry:hover {
    background: #f8f9fa;
  }

  .log-entry.registro {
    border-left: 4px solid #28a745;
  }

  .log-entry.reclamo {
    border-left: 4px solid #ffc107;
  }

  .log-icon {
    font-size: 20px;
    margin-right: 15px;
    min-width: 50px;
    text-align: center;
  }

  .log-content {
    flex: 1;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
  }

  .log-main {
    color: #495057;
    font-size: 14px;
  }

  .log-time {
    color: #6c757d;
    font-size: 12px;
    margin-left: 10px;
  }

  @media (max-width: 768px) {
    .logs-header {
      flex-direction: column;
      align-items: flex-start;
    }

    .refresh-btn {
      margin-top: 10px;
      align-self: flex-end;
    }

    .log-content {
      flex-direction: column;
      align-items: flex-start;
    }

    .log-time {
      margin-left: 0;
      margin-top: 5px;
    }
  }
</style>
