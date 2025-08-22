export enum TipoComida {
  ALMUERZO = 'almuerzo',
  CENA = 'cena'
}

export interface Plato {
  id: number;
  nombreEstudiante: string;
  tipoComida: TipoComida;
  disponible: boolean;
  reclamadoPor?: string;
  fechaCreacion: string;
  fechaReclamado?: string;
}

export interface PlatosResponse {
  almuerzo: Plato[];
  cena: Plato[];
}

export interface CreatePlatoDto {
  nombreEstudiante: string;
  tipoComida: TipoComida;
}

export interface ReclamarPlatoDto {
  reclamadoPor: string;
}
