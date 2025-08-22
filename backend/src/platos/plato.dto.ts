import { IsEnum, IsNotEmpty, IsString } from 'class-validator';
import { TipoComida } from './plato.entity';

export class CreatePlatoDto {
  @IsNotEmpty()
  @IsString()
  nombreEstudiante: string;

  @IsEnum(TipoComida)
  tipoComida: TipoComida;
}

export class ReclamarPlatoDto {
  @IsNotEmpty()
  @IsString()
  reclamadoPor: string;
}
