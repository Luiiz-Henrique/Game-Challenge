# Game-Challenge

Jogo de corrida infinita em Godot 4.7, feito para **mobile em portrait**.

- **Engine:** Godot 4.7 (renderer `mobile`)
- **Resolução:** 393 × 852 (portrait, `canvas_items` / `keep_width`)
- **Física:** Jolt Physics
- **Autoload:** `GameState` (`res://Core/GameState.gd`)
- **Cena principal:** `res://Contexts/MenuHomeContext/MenuHomeContext.tscn`

## Estrutura

```
Contexts/     telas e contextos do jogo (menu, jogo, pausa, colisão)
Core/         estado global e cenas base
Features/     sistemas do jogo (player, obstáculos, cenário, botões, HUD)
addons/       plugins do Godot
scripts/      utilitários de manutenção do repositório
```

## Setup

```bash
git clone <url-do-repo> Game-Challenge
cd Game-Challenge

git lfs install                                # filtros de clean/smudge do LFS
git config core.hooksPath .githooks            # hook de pre-commit (uma vez)
```

Abra o projeto no Godot 4.7. Na primeira abertura o Godot importa os assets.

> O `git lfs install` e obrigatório: sem ele os PNG/SVG são commitados como
> binário cru e o Git passa a gerar conflito falso de imagem no merge.
> Veja [CONTRIBUTING.md](CONTRIBUTING.md).

## Branches

| Branch | Uso |
|---|---|
| `main` | versão estável, builds publicadas |
| `development` | branch de integração, destino padrão de PR |
| `feature/*` | uma feature por branch, a partir de `development` |

Fluxo: `feature/*` → PR → `development` → `main`.

## Contribuindo

Leia o [CONTRIBUTING.md](CONTRIBUTING.md). Ele cobre as regras de assets
(Git LFS), o hook de pre-commit e o fluxo de trabalho com branches.
