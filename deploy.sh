#!/usr/bin/env bash
set -e

# Workaround Windows file lock: bash mantém deploy.sh aberto enquanto executa,
# impedindo que git checkout main o restaure no passo final. Rodar a partir de
# uma cópia em /tmp libera o arquivo original.
if [[ "$0" != /tmp/* ]]; then
  export DEPLOY_ROOT="$(cd "$(dirname "$0")" && pwd)"
  cp "$0" /tmp/deploy_run.sh
  exec bash /tmp/deploy_run.sh "$@"
fi

RSCRIPT="/c/Program Files/R/R-4.5.1/bin/Rscript.exe"
ROOT="${DEPLOY_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
RDS="$ROOT/intermediarios/priorizacao_trilhas_7_para_analise_com_bloco_04.rds"
JSON_DEST="$ROOT/painel/dados/trilhas.json"

echo "==> [1/5] Gerando trilhas.json a partir do RDS..."
"$RSCRIPT" - << 'EOF'
library(tidyverse)
library(jsonlite)

args <- commandArgs(trailingOnly = FALSE)
root <- normalizePath(dirname(sub("--file=", "", args[grep("--file=", args)])))

# fallback para working directory se chamado via -e / stdin
if (!nchar(root) || root == ".") root <- normalizePath(".")

rds_path  <- file.path(root, "intermediarios", "priorizacao_trilhas_7_para_analise_com_bloco_04.rds")
json_path <- file.path(root, "painel", "dados", "trilhas.json")

ranking_priorizacao <- readRDS(rds_path)

ranking_priorizacao %>%
  select(
    sre, municipio, id_municipio, id_mesorregiao, dc_mesorregiao,
    eixo_tecnologico, area_tecnologica, curso_tecnico,
    bloco, ranking, fl_municipio_prioritario
  ) %>%
  toJSON(auto_unbox = TRUE) %>%
  write(json_path)

cat(sprintf("trilhas.json gerado: %d registros\n", nrow(ranking_priorizacao)))
EOF

cd "$ROOT"

echo "==> [1b] Injetando versão no index.html..."
python - << 'PYEOF'
import re, datetime
ts = datetime.datetime.now().strftime('%d/%m/%Y %H:%M')
path = 'painel/index.html'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
content = re.sub(r'(id="painel-version">)[^<]*', r'\g<1>' + ts, content)
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('  Versao:', ts)
PYEOF

echo "==> [2/5] Commitando em main..."
git add -u
git diff --cached --quiet && echo "    Sem mudancas, nada a commitar." || \
  git commit -m "Atualiza painel (dados + UI)"

echo "==> [3/5] Push main..."
git push origin main

echo "==> [4/5] Atualizando gh-pages..."
cp "$JSON_DEST" /tmp/trilhas_deploy.json
cp "$ROOT/painel/index.html" /tmp/index_deploy.html

git checkout gh-pages
cp /tmp/trilhas_deploy.json dados/trilhas.json
cp /tmp/index_deploy.html index.html
git add dados/trilhas.json index.html
git diff --cached --quiet && echo "    Sem mudancas, nada a commitar." || \
  git commit -m "Deploy: atualiza painel"
git push origin gh-pages

echo "==> [5/5] Voltando para main..."
git checkout main

echo ""
echo "Pronto! Painel atualizado em:"
echo "https://lucaslbrandao.github.io/painel-trilhas-futuro/"
