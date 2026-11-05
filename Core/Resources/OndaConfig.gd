class_name OndaConfig
extends Resource

## Uma onda da fase: um trecho de pressão (padrões saindo) seguido de um
## trecho de calma (só o cenário corre). O PhaseConfig guarda a lista de
## ondas na ordem em que acontecem; a última se repete se a fase durar mais.

## Padrões que o DiretorPadroes pode sortear nesta onda.
@export_flags("Simples", "Tiro", "Combo", "Dupla", "Dupla + tiro", "Sequência") var padroes: int = 1

## Segundos de pressão, com padrões chegando ao jogador.
@export var duracao_pressao: float = 20.0

## Segundos de calma depois da pressão (0 = emenda na próxima onda).
@export var duracao_calma: float = 5.0

## Intervalo desejado (s) entre um padrão e o seguinte chegarem ao jogador.
## Menor = onda mais intensa. O diretor aumenta esse tempo sozinho quando
## o jogador precisaria de mais tempo para trocar de pista.
@export var intervalo_padroes: float = 1.5
