# Design System — Orientações Gerais

---

## Princípios

**Minimalismo funcional.** Cada elemento visual precisa cumprir uma função comunicativa clara. Formas, cores e pesos tipográficos existem para transmitir hierarquia e significado — não para decorar.

**Parcimônia de contêineres.** Caixas e bordas são usadas apenas quando a contenção visual organiza ou destaca informação que o texto e o espaçamento por si sós não comunicariam com a mesma clareza. Listas, grupos de texto e itens de uma mesma natureza não precisam de caixas.

**Hierarquia pelo tipo.** A diferenciação entre título, cabeçalho, corpo e caption é feita por tamanho, peso e cor — nunca por decoração.

**Consistência de acento.** As duas cores de acento têm papéis fixos e não são intercambiáveis. Azul escuro ancora estrutura e autoridade. Vinho marca ênfase e contraste.

---

## Paleta de Cores

| Token | Hex | Papel |
|---|---|---|
| `color-bg` | `#FFFFFF` | Fundo de todas as superfícies |
| `color-text-primary` | `#1C1C1C` | Títulos, texto principal |
| `color-text-secondary` | `#555555` | Texto de apoio, descrições |
| `color-text-caption` | `#888888` | Captions, notas, rodapés |
| `color-border` | `#DDDDDD` | Bordas de tabelas, separadores |
| `color-surface-note` | `#EEF2F7` | Fundo de alertas e caixas informativas |
| `color-accent-structure` | `#1B2A4A` | Cabeçalhos, painéis de destaque, elementos de autoridade |
| `color-accent-emphasis` | `#7B1F3A` | Ênfase, alertas, marcadores, bordas de destaque |
| `color-accent-positive` | `#2E6B3E` | Resultados positivos, reduções, efeitos benéficos |
| `color-text-on-dark` | `#FFFFFF` | Texto sobre `color-accent-structure` |
| `color-text-on-dark-secondary` | `#CADCFC` | Texto secundário sobre fundo escuro |

---

## Tipografia

Fonte única: **Roboto**. Dois pesos apenas: Regular (400) e Bold (700).

| Nível | Tamanho | Peso | Cor |
|---|---|---|---|
| Título de seção | 20–24pt | Bold | `#1C1C1C` |
| Cabeçalho de componente | 12–14pt | Bold | `#1B2A4A` |
| Corpo | 12–13pt | Regular | `#1C1C1C` |
| Texto secundário | 11–12pt | Regular | `#555555` |
| Caption / rodapé | 9–10pt | Regular | `#888888` |
| Número de destaque | 32–40pt | Bold | Contextual |

Títulos sempre em preto `#1C1C1C` — nunca coloridos. Cabeçalhos internos sempre em azul escuro `#1B2A4A`.

---

## Uso de Contêineres

Usar retângulos e bordas **apenas nos seguintes casos**:

- **Bloco de destaque escuro** — fundo `#1B2A4A`, texto branco — para definições centrais ou métricas de impacto alto.
- **Caixa de nota** — fundo `#EEF2F7`, borda `#1B2A4A` opacity 40% — para ressalvas, contexto ou alertas informativos.
- **Tabela** — cabeçalho `#1B2A4A` com texto branco, linhas com borda `#DDDDDD`.
- **Cartão de KPI** — fundo branco, borda `#DDDDDD`, barra lateral colorida para indicar valência.
- **Painéis comparativos** — dois blocos lado a lado com cabeçalhos coloridos quando a comparação é o argumento central.

**Não usar caixas** para agrupar listas, bullets, texto corrido ou itens de mesma natureza — usar espaçamento e hierarquia tipográfica.

---

## Valência de Cor

Quando um dado tem direção (positivo/negativo, aumento/redução), usar cor para comunicar isso de forma consistente:

- Neutro / estrutural → `#1B2A4A`
- Alerta / aumento indesejado → `#7B1F3A`
- Resultado positivo / redução → `#2E6B3E`

Nunca usar verde/vermelho convencionais — usar sempre os tokens acima para manter coerência com o restante da paleta.

---

## O que nunca fazer

- Gradientes, sombras, arredondamento de cantos, ícones decorativos ou qualquer efeito visual.
- Linha decorativa sob títulos.
- Fundo cinza em superfícies de conteúdo — apenas branco.
- Mais de dois pesos tipográficos.
- Títulos coloridos — sempre preto.
- Retângulos por hábito ou para preencher espaço.
- Inverter os papéis das cores de acento.
