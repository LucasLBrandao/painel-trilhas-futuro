# Especificação — Painel Interativo de Priorização Trilhas de Futuro

## Contexto

Painel HTML/JS estático (sem servidor) para exploração dos dados de priorização
de pares **curso técnico × município** do programa Trilhas de Futuro (SEE/MG).
O arquivo deve rodar diretamente no browser via `file://` ou servidor local simples.

---

## Estrutura de arquivos do projeto

```
validacao-priorizacao-final-trilhas-7-iet/
│
├── intermediarios/
│   └── priorizacao_trilhas_7_para_analise.rds   ← base principal (R)
│
├── entradas/
│   ├── municipios_mg_ibge.json
│   ├── POP2025_20260113.xls
│   ├── Superintendências_Regionais_de_Ensino_-SRE_com_municípios_de_sua_jurisdição_-_nov-2016.xlsx
│   └── mapas/
│       ├── MG_Municipios_2023/     ← shapefile municípios (SIRGAS 2000, CD_MUN 7 dígitos)
│       ├── MG_Mesorregioes_2022/   ← shapefile mesorregiões
│       └── SREs_com_BH/            ← shapefile SREs (48 regionais, CRS 4674)
│
└── painel/                         ← PASTA DE OUTPUT DO PAINEL
    ├── index.html                  ← arquivo principal (único entregável)
    └── dados/
        └── trilhas.json            ← base exportada do .rds para JSON (ver abaixo)
```

---

## Pré-requisito: exportar a base para JSON

Antes de construir o painel, exportar a base `.rds` e os shapes para JSON/GeoJSON
com o script R abaixo. Salvar os arquivos na pasta `painel/dados/`.

```r
library(tidyverse)
library(sf)
library(jsonlite)
library(stringi)

# --- Base de pares ---
ranking_priorizacao <- readRDS(
  "./intermediarios/priorizacao_trilhas_7_para_analise.rds"
)

ranking_priorizacao %>%
  select(
    sre, municipio, id_municipio, id_mesorregiao, dc_mesorregiao,
    eixo_tecnologico, area_tecnologica, curso_tecnico,
    bloco, ranking, fl_municipio_prioritario
  ) %>%
  toJSON(auto_unbox = TRUE) %>%
  write("./painel/dados/trilhas.json")

# --- GeoJSON municípios ---
shp_municipios <- st_read("./entradas/mapas/MG_Municipios_2023", quiet = TRUE) %>%
  mutate(id_municipio = as.integer(CD_MUN) %/% 10L) %>%
  select(id_municipio, NM_MUN) %>%
  st_transform(4326)

st_write(shp_municipios, "./painel/dados/municipios.geojson", delete_dsn = TRUE)

# --- GeoJSON SREs ---
normalizar_sre <- function(x) {
  x %>% str_trim() %>%
    stri_trans_general("Latin-ASCII") %>%
    str_to_lower()
}

shp_sres <- st_read("./entradas/mapas/SREs_com_BH", quiet = TRUE) %>%
  st_set_crs(4674) %>%
  st_make_valid() %>%
  mutate(
    Nome_SRE_norm = normalizar_sre(Nome_SRE) %>%
      str_replace("^municipio de belo horizonte$", "belo horizonte")
  ) %>%
  select(Nome_SRE, Nome_SRE_norm) %>%
  st_transform(4326)

st_write(shp_sres, "./painel/dados/sres.geojson", delete_dsn = TRUE)
```

> **Atenção IDs:** `id_municipio` na base usa 6 dígitos (sem dígito verificador).
> O shapefile usa 7 dígitos — o script já aplica `%/% 10L` para normalizar.
> O join SRE é feito por nome normalizado (sem acento, lowercase) para contornar
> divergências de capitalização entre o shapefile e a base.

---

## Funcionalidades

### Filtros (painel lateral ou topo)

Todos os filtros são cumulativos e se aplicam simultaneamente ao mapa, à tabela
e aos contadores de resumo.

| Filtro | Tipo | Campo na base |
|---|---|---|
| Bloco | Checkbox múltiplo (01 / 02 / 03) | `bloco` |
| Eixo tecnológico | Select múltiplo | `eixo_tecnologico` |
| Curso técnico | Select com busca | `curso_tecnico` |
| Município | Select com busca | `municipio` |
| Mesorregião | Select múltiplo | `dc_mesorregiao` |
| SRE | Select múltiplo | `sre` |
| Apenas municípios prioritários | Toggle (on/off) | `fl_municipio_prioritario` (não-NA) |

Botão **Limpar filtros** reseta tudo.

---

### Mapa interativo

- Biblioteca: **Leaflet.js** (via CDN)
- Alternância entre dois modos via botão toggle: **Municípios** / **SREs**
- Projeção: GeoJSON em WGS84 (já exportado com `st_transform(4326)`)

#### Modo Municípios
- Coroplético por **total de pares** (todos os blocos) após aplicação dos filtros
- Escala de cor: gradiente de `#94B2D7` (baixo) a `#174A7E` (alto)
- Municípios sem nenhum par nos dados filtrados: `#BFBEBE` (cinza)
- **Tooltip ao hover:**
  ```
  {Nome do Município} — {SRE}
  Total de pares: X
  Bloco 01: X | Bloco 02: X | Bloco 03: X
  ```

#### Modo SREs
- Coroplético por **bloco dominante** (bloco com mais pares na SRE após filtros)
- Regra: SREs com > 10 pares no Bloco 01 → sempre classificadas como Bloco 01
- Paleta:
  - Bloco 01: `#174A7E`
  - Bloco 02: `#2E8B57`
  - Bloco 03: `#F0C040`
  - Sem dados: `#BFBEBE`
- Intensidade (alpha) proporcional ao total de pares
- **Tooltip ao hover:**
  ```
  {Nome SRE}
  Total de pares: X
  Bloco 01: X | Bloco 02: X | Bloco 03: X
  Bloco dominante: Bloco XX
  ```
- Join SRE: usar `Nome_SRE_norm` (normalizado) como chave entre GeoJSON e base

---

### Contadores de resumo (cards no topo)

Atualizados dinamicamente conforme filtros:

| Card | Conteúdo |
|---|---|
| Total de pares | n pares nos dados filtrados |
| Pares Bloco 01 | n + % do total filtrado |
| Municípios cobertos | n distintos |
| SREs cobertas | n distintas |

---

### Tabela — base completa filtrada

- Biblioteca: **DataTables.js** (via CDN)
- Exibe todas as linhas que passaram pelos filtros
- Colunas visíveis por padrão:

| Coluna | Campo |
|---|---|
| SRE | `sre` |
| Município | `municipio` |
| Mesorregião | `dc_mesorregiao` |
| Eixo Tecnológico | `eixo_tecnologico` |
| Curso Técnico | `curso_tecnico` |
| Bloco | `bloco` |
| Ranking | `ranking` |
| Prioritário | `fl_municipio_prioritario` |

- Paginação: 25 linhas por página
- Busca global nativa do DataTables
- Ordenação por qualquer coluna
- Coluna `bloco` com badge colorido:
  - Bloco 01: badge azul `#174A7E`
  - Bloco 02: badge verde `#2E8B57`
  - Bloco 03: badge amarelo `#F0C040`

---

## Estilo visual

- Paleta SWD do projeto:
  ```
  BLUE1   = #174A7E
  BLUE3   = #94B2D7
  GRAY9   = #BFBEBE
  GRAY3   = #555655
  GREEN   = #2E8B57
  YELLOW  = #F0C040
  ```
- Fonte: **IBM Plex Sans** (Google Fonts) — corpo; **IBM Plex Mono** para badges e números
- Layout: sidebar de filtros à esquerda (largura fixa ~280px) + área principal à direita
- Área principal: cards de resumo no topo → mapa → tabela (scroll contínuo)
- Responsivo não é requisito — desktop first

---

## Restrições técnicas

- **Zero dependências de servidor** — tudo via CDN ou inline
- Bibliotecas via CDN (versões fixas):
  - Leaflet.js `1.9.4`
  - DataTables `1.13.6` + jQuery `3.7.0`
  - Google Fonts (IBM Plex Sans + IBM Plex Mono)
- Os três arquivos de dados (`trilhas.json`, `municipios.geojson`, `sres.geojson`)
  são carregados via `fetch()` — o painel deve ser aberto via servidor local
  (`python -m http.server` na pasta `painel/`) por restrição de CORS do `file://`
- Arquivo único: todo CSS e JS inline no `index.html`; os três JSONs ficam em `painel/dados/`

---

## Versionamento automático

A cada execução do `deploy.sh`, a data e hora de publicação são injetadas automaticamente no `index.html` e exibidas abaixo do subtítulo "Priorização Curso × Município" na sidebar.

- **Elemento HTML:** `<div class="sidebar-version" id="painel-version">—</div>`
- **Formato exibido:** `DD/MM/AAAA HH:MM` (ex.: `16/04/2026 14:32`)
- **Mecanismo:** `deploy.sh` usa Python para substituir o conteúdo do elemento via regex antes do commit, garantindo compatibilidade com Windows/Git Bash.
- O placeholder `—` é exibido em ambiente de desenvolvimento local (sem deploy).

---

## Entregável esperado

```
painel/
├── index.html
└── dados/
    ├── trilhas.json        ← gerado pelo script R acima
    ├── municipios.geojson  ← gerado pelo script R acima
    └── sres.geojson        ← gerado pelo script R acima
```

Para rodar:
```bash
cd validacao-priorizacao-final-trilhas-7-iet/painel
python -m http.server 8000
# abrir http://localhost:8000
```
