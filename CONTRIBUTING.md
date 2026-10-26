# Contribuindo no Game-Challenge

Este documento tem as regras que evitam os conflitos de merge do projeto.
O ponto mais importante é o **Git LFS** — foi a causa raiz dos conflitos de
imagem que o time vinha enfrentando.

---

## 1. Setup (uma vez por máquina)

```bash
git lfs install                    # filtros de clean/smudge do LFS
git config core.hooksPath .githooks # ativa o hook de pre-commit
```

Sem o `git lfs install`, os PNG/SVG são commitados como binário cru. Com isso,
o Git passa a tentar mesclar *textualmente* um ponteiro LFS (3 linhas) com o
arquivo real (um SVG de 186 linhas) e gera conflito falso, com marcadores
`<<<<<<<` dentro do asset.

O diretório `.githooks/` é versionado e contém o nosso `pre-commit` **e** os
hooks do próprio Git LFS (`pre-push`, `post-commit`, `post-checkout`,
`post-merge`). O `pre-push` é o que garante que os objetos LFS sejam enviados
ao servidor — não apague esses arquivos. O `git lfs install` pode reescrevê-los
(idêntico ao que está versionado), então um `git status` sujo depois do setup
é normal.

## 2. Regras de assets

1. **Um asset novo entra junto do `.import`, no mesmo commit.**
   O `.import` guarda o `uid`, o `path` do cache e os parâmetros de importação.
   Asset sem `.import` no commit quebra o projeto de quem pullar.

2. **Nunca renomear um asset.**
   Renomear (deletar + adicionar) regenera o `uid`, o `path` e o `dest_files`
   dentro do `.import`, e o Git entende como "arquivo novo" + "arquivo
   removido" — gerando conflito na hora do merge.
   Se precisar renomear, **avise no PR** para o conteúdo poder ser reconciliado
   junto.

3. **Um dono por asset binário.**
   Antes de trocar uma imagem que já existe, avise quem é o responsável.
   Duas pessoas alterando o mesmo PNG ao mesmo tempo é conflito garantido.

4. **Evite espaços e acentos no nome do arquivo.**
   O projeto ainda tem `Tela Inicial.png`, `botaoJogar 1.svg` e
   `CenarioVerão.png`. Funcionam, mas quebram scripts e ferramentas que não
   escapam o path. Novos assets: use `snake_case` sem espaços.

5. **Cenas (`.tscn`) e recursos (`.tres`) NÃO vão para o LFS.**
   Eles são texto e precisam de diff/merge legíveis. Só *assets* (imagem,
   áudio, modelo 3D) vão para o LFS.

## 3. O hook de pre-commit

O hook versionado em `.githooks/pre-commit` bloqueia o commit quando:

- um PNG/SVG/JPG/WebP/MP3/WAV/… está staged mas **fora do LFS**
- um `.DS_Store` está staged

E avisa (sem bloquear) quando um asset novo é adicionado sem o `.import`
correspondente.

Para desativar temporariamente: `git commit --no-verify`.

## 4. Fluxo de trabalho

```bash
git fetch origin
git checkout -b feature/minha-feature origin/development
# ... worked ...
git add -A
git commit -m "feat: descricao curta"
git push origin feature/minha-feature
```

Antes de abrir o PR, integre a `development` na sua branch:

```bash
git fetch origin
git merge origin/development
```

Assim o conflito aparece na sua máquina, não no PR de alguém.

## 5. Branch antiga com asset fora do LFS

Se sua branch foi criada antes de o projeto passar a usar LFS, ela ainda tem
os assets em binário cru. Normalize antes de fazer merge:

```bash
git checkout <sua-branch>
./scripts/normalize-lfs.sh
```

O script roda `git add --renormalize .` e commita. É um commit normal, sem
force-push e sem reescrever histórico. Ele também avisa se a branch tem
commits locais ainda **não enviados** ao remoto — nesse caso, envie antes
(`git push origin <branch>`), senão a normalização pode reordenar o
histórico local.

Depois é só:

```bash
git push origin <sua-branch>
```

O resultado é byte-idêntico ao da `development` (mesmo `oid sha256`), então o
merge passa a ser limpo.

## 6. Antes de abrir o PR

- [ ] `git fetch && git merge origin/development` — sem conflito
- [ ] Rodou o jogo no Godot depois das mudanças
- [ ] Asset novo está com o `.import` no mesmo commit
- [ ] Commit message no formato `feat:`, `fix:`, `chore:`, `docs:`
