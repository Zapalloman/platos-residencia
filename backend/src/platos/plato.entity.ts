import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

export enum TipoComida {
  ALMUERZO = 'almuerzo',
  CENA = 'cena'
}

@Entity()
export class Plato {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  nombreEstudiante: string;

  @Column({
    type: 'simple-enum',
    enum: TipoComida,
  })
  tipoComida: TipoComida;

  @Column({ default: true })
  disponible: boolean;

  @Column({ nullable: true })
  reclamadoPor: string;

  @CreateDateColumn()
  fechaCreacion: Date;

  @Column({ nullable: true })
  fechaReclamado: Date;
}
