# Política de Sanitização / Sanitization Policy

## Português

### Objetivo

Esta política define como transformar aprendizados do ambiente operacional privado do MLI-Knot LAB-CLUSTER em documentação, exemplos e scripts adequados para publicação.

Sanitizar não significa apenas apagar senhas. O processo deve impedir que pessoas externas reconstruam a topologia, a identidade dos equipamentos, os mecanismos de acesso ou o histórico operacional do laboratório.

### Princípio de derivação

Toda publicação deve ser uma **derivação curada**.

O repositório público:

- possui histórico Git independente;
- recebe apenas conteúdo selecionado;
- utiliza exemplos reconstruídos;
- não importa commits da fonte privada;
- não copia checkpoints brutos;
- não funciona como backup do ambiente operacional;
- não deve permitir reconstrução da topologia privada.

### Regra de seleção

O conteúdo começa bloqueado.

Um arquivo ou trecho somente pode ser publicado quando:

1. possui valor educacional ou de portfólio claramente identificado;
2. pode ser compreendido sem dados reais;
3. foi reescrito ou parametrizado;
4. passou pela auditoria automática;
5. foi revisado manualmente;
6. foi aprovado no diff público.

A ausência de uma correspondência em uma lista de bloqueio não torna o conteúdo automaticamente seguro.

### Matriz de transformação

| Material operacional | Transformação pública obrigatória |
|---|---|
| Nome real de máquina | Papel genérico, como `control-node` ou `worker-01` |
| Endereço real | Endereço reservado exclusivamente para documentação |
| Usuário de acesso | Variável `REMOTE_USER` |
| Caminho pessoal | Variável como `$HOME` ou diretório fictício |
| Endereço físico de interface | Omitir integralmente |
| Inventário real | Criar inventário fictício mínimo |
| Capacidade exata de hardware | Usar valor sintético ou descrição qualitativa |
| Log bruto | Produzir pequeno exemplo fictício e identificado |
| Data e identificador operacional | Usar marco evolutivo ou valor sintético |
| Configuração de autenticação | Descrever o princípio sem publicar a configuração real |
| Referência a repositório privado | Usar a expressão `fonte operacional privada` |
| Commit ou hash privado | Omitir |
| Checkpoint bruto | Consolidar o aprendizado em narrativa pública |
| Script operacional | Parametrizar, reduzir privilégios e revisar comandos |
| Saída real de comando | Substituir por resultado sintético coerente |

### Dados permitidos para documentação

Os exemplos podem utilizar os blocos reservados para documentação:

| Uso | Faixa |
|---|---|
| Exemplo A | `192.0.2.0/24` |
| Exemplo B | `198.51.100.0/24` |
| Exemplo C | `203.0.113.0/24` |

Esses endereços devem aparecer somente como exemplos e nunca como alegação de topologia ativa.

Hostnames públicos recomendados:

- `control-node`;
- `worker-01`;
- `worker-02`;
- `worker-03`.

Identidades públicas recomendadas:

- `REMOTE_USER`;
- `CONTROL_HOST`;
- `HOSTS_FILE`;
- `LOG_DIR`;
- `JOB_ROOT`.

### Conteúdo que deve permanecer privado

Devem permanecer exclusivamente no ambiente operacional:

- inventários reais;
- detalhes físicos dos equipamentos;
- endereços e segmentação reais;
- identificadores de interfaces;
- usuários e métodos reais de acesso;
- regras reais de privilégio;
- arquivos de autenticação;
- logs completos;
- resultados operacionais não revisados;
- checkpoints históricos brutos;
- comandos ligados a caminhos ou identidades reais;
- backups e exportações do laboratório;
- estados de serviços que revelem a superfície operacional;
- histórico Git da fonte privada.

### Scripts públicos

Um script derivado somente pode ser publicado quando:

- aceita inventário e usuário por variável ou argumento;
- não contém destino real embutido;
- não depende de caminho pessoal fixo;
- não pressupõe autenticação sem interação;
- não amplia privilégios silenciosamente;
- apresenta uso e limitações;
- falha de forma explícita;
- registra operações sem expor segredos;
- exige confirmação para ações administrativas;
- contém exemplos fictícios;
- foi revisado separadamente do script privado.

A versão pública não precisa reproduzir integralmente a versão operacional. Clareza e segurança têm prioridade sobre equivalência literal.

### Documentos públicos

Documentos derivados devem:

- consolidar aprendizados em vez de copiar checkpoints;
- separar estado histórico de estado atual;
- declarar quando um resultado é sintético;
- omitir hashes e referências privadas;
- evitar precisão desnecessária sobre hardware e rede;
- explicar decisões sem expor mecanismos de acesso;
- manter português e inglês quando fizer parte da superfície principal.

### Invariante visual do README

Todo repositório principal do ecossistema deve possuir o GIF Matrix canônico no `README.md` da raiz.

URL canônica:

`https://raw.githubusercontent.com/proftectiagocosta-hash/mli-knot-mind-public/main/assets/matrix-inspired-banner.gif`

Regras:

- o título principal deve aparecer antes do banner;
- o banner deve ficar dentro de `<div align="center">`;
- a largura deve ser `100%`;
- a URL canônica deve aparecer exatamente uma vez;
- o banner não substitui o título ou a descrição textual;
- a auditoria de publicação deve interromper o processo se o banner estiver ausente.

### Estrutura permitida

A vitrine pública utiliza uma lista explícita de caminhos:

- arquivos institucionais na raiz;
- documentação curada em `docs/`;
- inventários fictícios em `examples/`;
- scripts sanitizados em `scripts/`;
- ferramentas de auditoria em `tools/`;
- recursos visuais públicos em `assets/`, quando necessários.

Diretórios de checkpoints brutos, logs, estados, backups, inventários reais e exportações privadas não pertencem à estrutura pública.

### Revisão obrigatória

Antes de cada commit público, confirmar:

- [ ] somente arquivos esperados foram alterados;
- [ ] nenhum arquivo veio acompanhado de histórico privado;
- [ ] o README principal contém o banner Matrix canônico;
- [ ] não existem credenciais ou materiais de autenticação;
- [ ] não existem endereços privados ou identificadores físicos;
- [ ] nomes de máquinas e usuários são genéricos;
- [ ] caminhos são parametrizados;
- [ ] logs e saídas são sintéticos;
- [ ] scripts possuem limites e instruções;
- [ ] a auditoria automática foi concluída;
- [ ] o diff preparado para commit foi lido integralmente;
- [ ] a atualização será publicada por Pull Request.

### Regra de dúvida

Se houver dúvida sobre a possibilidade de um dado identificar o ambiente real, o dado permanece privado.

A vitrine pode ser ampliada posteriormente. Uma exposição pública não pode ser desfeita com a mesma segurança.

---

## English

### Purpose

This policy defines how private operational learning from MLI-Knot LAB-CLUSTER is transformed into public documentation, examples, and scripts.

Sanitization is broader than secret removal. Public material must not allow reconstruction of the lab topology, machine identities, access mechanisms, or operational history.

### Curated derivation

Every public update is rebuilt as a curated derivative with independent Git history. Raw checkpoints, private commits, real inventory, direct exports, and private branches are never imported.

### Transformation rules

Real hostnames become role-based names. Real addresses become documentation-only addresses. Users and paths become variables. Hardware identifiers are removed. Raw logs become synthetic excerpts. Private checkpoints become consolidated learning narratives.

### Public scripts

A public script must be parameterized, privilege-aware, explicit about failure, documented, free of embedded real targets, and independently reviewed.

### README visual invariant

The root `README.md` must contain the canonical Matrix GIF exactly once, centered at full width and placed after the main title.

### Publication decision

When the safety of a value is uncertain, keep it private. Public scope can be expanded later; accidental disclosure cannot be reliably undone.
