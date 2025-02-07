package com.tasksave.api.models;

import lombok.*;
import  jakarta.persistence.*;


@Entity // Diz ao Hibernate que essa classe será uma tabela no banco de dados, ou seja todos os seus atributos serão campos na tabela
@Table(name = "priority") // Reforça ao Hibernate que a classe será uma tabela, podendo completar com parâmetros como nome
@Data // Anotação do Lombok que gera Getter, Setter, equals, e hashcode de forma automática
@NoArgsConstructor // Construtor sem argumentos, necessário para o JPA!
@AllArgsConstructor // Cria um construtor com todos os argumentos
@Builder(toBuilder = true) // Implementa o padrão Builder de instancição
public class Priority {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true) // length default = 255
    private String description;

    @Column(nullable = false, unique = true) // length default = 255
    private String color;
}
