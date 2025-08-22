import type { Plato, PlatosResponse, CreatePlatoDto, ReclamarPlatoDto } from '../types';

// Detectar si estamos en desarrollo local o acceso desde red
const getApiUrl = () => {
  if (typeof window !== 'undefined') {
    const hostname = window.location.hostname;
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'http://localhost:3000';
    } else {
      // Si accedemos desde otra IP, usar la misma IP para el backend
      return `http://${hostname}:3000`;
    }
  }
  return 'http://localhost:3000';
};

const API_URL = getApiUrl();

class ApiService {
  private async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const url = `${API_URL}${endpoint}`;
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!response.ok) {
      throw new Error(`Error ${response.status}: ${response.statusText}`);
    }

    return response.json();
  }

  async obtenerPlatosDisponibles(): Promise<PlatosResponse> {
    return this.request<PlatosResponse>('/platos/disponibles');
  }

  async obtenerTodosLosPlatos(): Promise<PlatosResponse> {
    return this.request<PlatosResponse>('/platos');
  }

  async obtenerEstadisticas(): Promise<{
    totalPlatos: number;
    platosDisponibles: number;
    platosReclamados: number;
    almuerzoDisponible: number;
    cenaDisponible: number;
  }> {
    return this.request('/platos/estadisticas');
  }

  async crearPlato(plato: CreatePlatoDto): Promise<Plato> {
    return this.request<Plato>('/platos', {
      method: 'POST',
      body: JSON.stringify(plato),
    });
  }

  async reclamarPlato(id: number, reclamarDto: ReclamarPlatoDto): Promise<Plato> {
    return this.request<Plato>(`/platos/${id}/reclamar`, {
      method: 'PATCH',
      body: JSON.stringify(reclamarDto),
    });
  }

  async eliminarPlato(id: number): Promise<void> {
    await this.request(`/platos/${id}`, {
      method: 'DELETE',
    });
  }
}

export const api = {
  async obtenerPlatosDisponibles() {
    const response = await fetch(`${API_URL}/platos/disponibles`);
    if (!response.ok) throw new Error('Error al obtener platos');
    return response.json();
  },

  async crearPlato(plato: { nombreEstudiante: string; tipoComida: string }) {
    const response = await fetch(`${API_URL}/platos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(plato),
    });
    if (!response.ok) throw new Error('Error al crear plato');
    return response.json();
  },

  async reclamarPlato(id: number, nombreReclamante: string) {
    const response = await fetch(`${API_URL}/platos/${id}/reclamar`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ reclamadoPor: nombreReclamante }),
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error('Error response:', errorText);
      throw new Error(`Error al reclamar plato: ${response.status} - ${errorText}`);
    }
    
    return response.json();
  },

  async obtenerEstadisticas() {
    const response = await fetch(`${API_URL}/platos/estadisticas`);
    if (!response.ok) throw new Error('Error al obtener estadísticas');
    return response.json();
  }
};
