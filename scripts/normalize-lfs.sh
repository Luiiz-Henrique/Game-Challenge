#!/usr/bin/env bash
#
# Normaliza a branch atual para Git LFS.
#
# Contexto: as branches antigas ficaram com PNG/SVG commitados como binario
# cru, enquanto a `development` usa LFS. Isso faz o Git tentar mesclar um
# ponteiro LFS (3 linhas) com o arquivo real (um SVG de 186 linhas) e
# produzir conflito falso, com marcadores "<<<<<<<" dentro do asset.
#
# Este script converte os binarios crus da branch em ponteiros LFS. O
# resultado e byte-identico ao da `development` (mesmo oid sha256), entao o
# merge passa a ser limpo. Commit normal, sem force-push, sem reescrever
# historico.
#
# Uso:
#   git checkout <sua-branch>
#   ./scripts/normalize-lfs.sh
#
set -euo pipefail

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" = "HEAD" ]; then
    echo "ERRO: voce esta em detached HEAD. Faca checkout de uma branch." >&2
    exit 1
fi

echo "==> Normalizando branch: $branch"

if ! command -v git-lfs >/dev/null 2>&1 && ! git lfs version >/dev/null 2>&1; then
    echo "ERRO: Git LFS nao esta instalado. Instale e rode 'git lfs install'." >&2
    exit 1
fi

git lfs install
git fetch origin

# Avisa sobre commits nao enviados / branch atrasada. Normalizar uma branch
# com trabalho local nao enviado pode reordenar o historico e perder commits.
remote_ref="origin/$branch"
if git rev-parse --verify --quiet "$remote_ref" >/dev/null 2>&1; then
    ahead=$(git rev-list --count "$remote_ref..HEAD")
    behind=$(git rev-list --count "HEAD..$remote_ref")
    if [ "$ahead" -gt 0 ]; then
        echo "AVISO: '$branch' tem $ahead commit(s) local(is) ainda NAO enviado(s):"
        git log --oneline "$remote_ref..HEAD" | sed 's/^/         - /'
        echo "       Envie-os ANTES de normalizar: git push origin $branch"
        echo "       (ou pare aqui e continue depois)"
    fi
    if [ "$behind" -gt 0 ]; then
        echo "AVISO: '$branch' esta $behind commit(s) atrasada em relacao a 'origin/$branch'."
        echo "       Sincronize antes: git pull --rebase origin $branch"
    fi
else
    echo "AVISO: '$branch' ainda nao existe no remoto ('origin/$branch')."
fi

git add --renormalize .

if git diff --cached --quiet; then
    echo "==> Nada a fazer: '$branch' ja esta normalizada."
    exit 0
fi

echo "==> Arquivos convertidos:"
git diff --cached --stat

git commit -m "chore: converte assets para LFS"

echo "==> Pronto. Agora envie com:"
echo "    git push origin $branch"
