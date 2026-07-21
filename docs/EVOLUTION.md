# Evolução do LAB-CLUSTER / LAB-CLUSTER Evolution

## Português

### Natureza desta linha evolutiva

Este documento consolida aprendizados registrados durante a construção histórica do MLI-Knot LAB-CLUSTER.

Cada fase descrita abaixo foi registrada como validada ou aplicada no ambiente privado no momento correspondente. Essa classificação histórica não confirma que a infraestrutura física esteja atualmente ligada, acessível ou com a mesma configuração.

A linha pública:

- preserva a ordem dos aprendizados;
- descreve capacidades e decisões;
- registra falhas e correções relevantes;
- omite topologia, inventário, identidades e saídas reais;
- não substitui a documentação operacional privada;
- será ampliada somente depois que novos marcos forem validados e sanitizados.

---

## Ciclo 1 — Fundação e conectividade

### Fase 1 — Base Linux e rede do laboratório

**Objetivo:** preparar o laboratório físico para operar como um conjunto coordenado de máquinas Linux.

**Aprendizado consolidado:**

- separação entre nó de controle e workers;
- instalação e preparação dos sistemas;
- organização de uma rede dedicada ao laboratório;
- definição inicial de responsabilidades;
- validação gradual antes de introduzir automação.

**Resultado público:** arquitetura básica de controle e execução estabelecida em ambiente isolado.

### Fase 2 — Disponibilidade e acesso remoto

**Objetivo:** confirmar comunicação entre o nó de controle e os workers.

**Aprendizado consolidado:**

- verificação de disponibilidade antes de qualquer comando;
- administração remota como fundação das próximas etapas;
- necessidade de timeouts e falhas explícitas;
- separação entre host inacessível e comando malsucedido.

**Resultado público:** conectividade e acesso remoto historicamente validados.

### Fase 3 — Autenticação remota por chave

**Objetivo:** reduzir intervenção manual sem incorporar credenciais aos scripts.

**Aprendizado consolidado:**

- automação não deve armazenar senhas;
- identidades e chaves permanecem fora do código;
- autenticação deve ser configurada e validada separadamente;
- ausência de interação não equivale a ausência de controle.

**Resultado público:** autenticação remota adequada ao laboratório foi validada sem tornar credenciais parte dos artefatos versionados.

### Fase 4 — Inventário remoto automatizado

**Objetivo:** obter uma visão básica e repetível da saúde dos workers.

**Aprendizado consolidado:**

- disponibilidade;
- identificação lógica;
- tempo de atividade;
- versão de sistema;
- memória;
- armazenamento;
- interfaces de rede.

**Resultado público:** primeiro inventário remoto executado de forma coordenada.

---

## Ciclo 2 — Controle operacional e segurança

### Fase 5 — Execução remota em lote

**Objetivo:** executar comandos comuns em vários workers a partir do nó de controle.

**Aprendizado consolidado:**

- leitura do inventário por arquivo configurável;
- execução por host;
- timeouts de conexão;
- identificação da saída por worker;
- logs por rodada;
- distinção entre comandos comuns e administrativos.

**Limite preservado:** essa etapa não concedeu automaticamente autorização para operações privilegiadas.

### Fase 6 — Padronização e auditoria dos workers

**Objetivo:** confirmar que os workers possuíam uma base operacional coerente.

**Aprendizado consolidado:**

- sincronização de tempo;
- estado dos serviços essenciais;
- presença de ferramentas básicas;
- coleta de memória e armazenamento;
- auditoria repetível antes de alterações;
- comparação de resultados entre workers.

**Resultado público:** auditoria operacional básica historicamente validada.

### Fase 7 — Administração controlada

**Objetivo:** criar uma camada separada para comandos administrativos.

**Aprendizado consolidado:**

- confirmação textual explícita antes da execução;
- exibição prévia do comando;
- bloqueio de padrões críticos conhecidos;
- registro da operação;
- captura do estado de saída por worker;
- manutenção da separação entre uso comum e uso privilegiado.

**Limite preservado:** a confirmação reduz riscos, mas não substitui revisão humana, menor privilégio ou testes em um único nó.

### Fase 8 — Manutenção com auditoria antes e depois

**Objetivo:** estruturar uma rotina de manutenção observável e reversível.

**Aprendizado consolidado:**

1. auditar o estado inicial;
2. atualizar índices;
3. listar mudanças disponíveis;
4. decidir explicitamente se a atualização deve ocorrer;
5. executar limpeza controlada;
6. auditar novamente;
7. preservar logs.

**Resultado público:** o ciclo completo foi historicamente validado com verificação final de saúde.

### Fase 9A — Preservação dos ativos operacionais

**Objetivo:** versionar os principais scripts e documentar procedimentos antes de ampliar a arquitetura.

**Aprendizado consolidado:**

- scripts ativos precisam de fonte controlada;
- procedimentos de maior risco podem ser preservados primeiro como documentação;
- documentação operacional e executável possuem riscos diferentes;
- versionar não significa declarar que o conteúdo continua válido para o ambiente atual.

### Marco intermediário — Rastreabilidade e indexação

**Objetivo:** garantir que checkpoints, estado e índices apontassem para a mesma etapa do laboratório.

**Aprendizado consolidado:**

- salvar arquivos não encerra um ciclo de documentação;
- estado, índice e checkpoint precisam permanecer coerentes;
- uma linha auxiliar não deve sobrescrever o estado global de outros projetos;
- rastreabilidade precisa indicar claramente qual fonte governa cada domínio.

### Fase 9B — Teste de restauração

**Objetivo:** provar que os scripts preservados podiam ser restaurados sem substituir imediatamente os arquivos ativos.

**Aprendizado consolidado:**

- restauração deve ocorrer primeiro em diretório isolado;
- arquivos restaurados devem ser comparados;
- testes funcionais devem preceder substituição;
- backup não validado é apenas uma cópia;
- restauração comprovada é uma capacidade operacional.

**Resultado público:** restauração e teste funcional historicamente validados sem alteração direta do ambiente ativo.

---

## Ciclo 3 — Computação distribuída

### Fase 10 — Jobs paralelos iniciais

**Objetivo:** superar a administração remota simples e executar trabalho coordenado.

**Aprendizado consolidado:**

- disparo paralelo;
- um log por worker;
- espera pela conclusão;
- consolidação de estados;
- distinção entre execução distribuída e simples repetição de comandos.

**Resultado público:** primeira camada de computação distribuída historicamente validada.

### Fase 11A — Monitor textual de jobs

**Objetivo:** tornar os jobs observáveis depois da execução.

**Aprendizado consolidado:**

- listar execuções;
- visualizar resumo;
- abrir detalhes;
- inspecionar logs por worker;
- consultar execuções anteriores sem relançar tarefas.

### Fase 11B — Divisão de trabalho em fatias

**Objetivo:** atribuir partes diferentes de um mesmo trabalho aos workers.

**Aprendizado consolidado:**

- divisão de um intervalo em partes;
- tratamento de divisões não exatas;
- identificação de cada fatia;
- execução paralela;
- resultados parciais por worker;
- necessidade de verificar cobertura e limites.

**Limite preservado:** produzir resultados parciais ainda não significava possuir um resultado global automaticamente validado.

### Fase 11C — Agregação de resultados

**Objetivo:** recompor o resultado final a partir das partes processadas.

**Aprendizado consolidado:**

- validação de cada resultado parcial;
- detecção de lacunas;
- detecção de sobreposição;
- conferência da quantidade processada;
- agregação final;
- teste negativo para comprovar a falha esperada.

**Resultado público:** ciclo de divisão, processamento, coleta e recomposição historicamente validado.

### Fase 11D — Pipeline integrado

**Objetivo:** executar distribuição e agregação como uma única operação controlada.

**Fluxo consolidado:**

`entrada → divisão → execução → coleta → agregação → validação`

**Aprendizado consolidado:**

- composição de ferramentas pequenas;
- propagação de códigos de saída;
- identificação inequívoca do job;
- interrupção diante de falha;
- confirmação explícita do resultado final.

---

## Ciclo 4 — Observabilidade e maturidade operacional

### Fase 12A — Monitoramento de jobs comuns e fatiados

**Objetivo:** unificar a leitura dos diferentes tipos de execução.

**Aprendizado consolidado:**

- filtros por tipo;
- detalhes específicos por modalidade;
- compatibilidade com jobs anteriores;
- inspeção do último job ou de um identificador selecionado.

### Fase 12B — Métricas históricas

**Objetivo:** transformar logs acumulados em informação operacional.

**Aprendizado consolidado:**

- resumo geral;
- métricas por worker;
- histórico recente;
- contagem de sucessos e falhas;
- relatórios persistidos;
- separação entre log bruto e visão consolidada.

### Fase 12C — Fila simples de jobs

**Objetivo:** introduzir uma camada mínima de agendamento manual.

**Estados conceituais:**

`pending → running → done | failed`

**Aprendizado consolidado:**

- cadastro de trabalhos;
- execução do próximo item;
- execução dos pendentes;
- movimentação por estado;
- logs próprios por item;
- preservação do resultado após a execução.

### Fase 12D — Inspeção da fila

**Objetivo:** melhorar a observabilidade da fila sem criar uma plataforma complexa.

**Aprendizado consolidado:**

- filtros por estado;
- listagem de logs recentes;
- consulta do último job;
- consulta do último job concluído;
- inspeção por identificador;
- tratamento claro de conjuntos vazios.

### Fase 12E — Dashboard textual consolidado

**Objetivo:** reunir a visão operacional em uma única interface textual.

**Camadas reunidas:**

- estado local;
- saúde dos workers;
- fila;
- logs recentes;
- métricas históricas;
- últimos jobs;
- alertas básicos.

**Resultado público:** dashboard completo, modo rápido e salvamento de relatório foram historicamente validados.

### Microfase 12E-FIX — Correção de leitura do inventário

**Problema identificado:** uma chamada remota dentro do loop consumia a mesma entrada utilizada para percorrer o inventário. Como consequência, somente o primeiro worker aparecia em uma seção do dashboard.

**Correção conceitual:** separar a entrada do loop da entrada usada pela chamada remota.

**Aprendizado consolidado:**

- descritores de entrada importam em loops de shell;
- uma saída parcialmente correta pode esconder falha de iteração;
- dashboards precisam ser confrontados com a fonte de inventário;
- correções pequenas também exigem evidência de regressão resolvida.

### Fase 12F — Marco operacional V1

**Objetivo:** registrar um ponto de maturidade antes de novas expansões.

**Capacidades consolidadas:**

- inventário;
- execução remota;
- administração controlada;
- manutenção;
- restauração;
- jobs paralelos;
- divisão e agregação;
- pipeline;
- monitoramento;
- métricas;
- fila;
- inspeção de logs;
- dashboard textual.

**Resultado público:** o conjunto foi classificado historicamente como marco operacional V1.

### Fase 12G — Exportação estruturada

**Objetivo:** transformar métricas em formatos reutilizáveis.

**Aprendizado consolidado:**

- exportação CSV para inspeção tabular;
- exportação JSON para consumo por ferramentas;
- manifesto e resumo;
- validação de contagens;
- separação entre geração de métricas e publicação de dados.

---

## Ciclo 5 — Persistência, visualização e consulta

### Fase 13 — Armazenamento simples

**Objetivo:** preservar snapshots das exportações sem introduzir banco de dados.

**Modelo consolidado:**

- armazenamento baseado em arquivos;
- registros acrescentados sem reescrever snapshots anteriores;
- índice consultável;
- ponte para o snapshot mais recente;
- separação entre exportar e armazenar.

**Resultado público:** camada simples de persistência historicamente validada.

### Fase 14 — Dashboard textual V2

**Objetivo:** utilizar o armazenamento como fonte principal da visualização consolidada.

**Aprendizado consolidado:**

- leitura do snapshot mais recente;
- resumo de jobs e workers;
- visualização de fila e métricas armazenadas;
- conferência separada do estado vivo;
- distinção entre observação histórica e consulta atual.

### Marco arquitetural pós-Fase 14

A arquitetura foi congelada temporariamente como referência antes de novas decisões.

**Capacidade demonstrada:**

O laboratório conseguia executar, dividir, agregar, medir, exportar, armazenar e visualizar resultados de forma controlada.

**O que isso não significava:**

- não era um supercomputador transparente;
- não combinava automaticamente memória ou processadores;
- não era armazenamento distribuído;
- não era uma plataforma completa de orquestração;
- não possuía banco de dados completo;
- não possuía interface web;
- não deveria armazenar credenciais permanentes.

### Fase 15 — API local mínima e somente leitura

**Objetivo:** disponibilizar informações selecionadas por uma interface local sem permitir mutações.

**Decisões de segurança consolidadas:**

- acesso restrito à própria máquina;
- somente leitura;
- nenhuma execução remota iniciada pela API;
- nenhum endpoint de alteração;
- fonte baseada nos dados já armazenados;
- expansão condicionada a nova decisão arquitetural.

**Resultado público:** API local mínima historicamente validada como camada de consulta.

---

## Estado público atual

A primeira versão desta vitrine encerra sua linha histórica na Fase 15.

Isso significa apenas que o aprendizado até esse ponto foi consolidado. Não significa que:

- o laboratório esteja atualmente ativo;
- os mesmos equipamentos continuem disponíveis;
- a topologia privada permaneça igual;
- os scripts públicos sejam cópias dos scripts operacionais;
- uma fase futura esteja automaticamente autorizada.

## Como esta linha será atualizada

Uma nova fase pública somente será adicionada quando:

1. houver avanço real no laboratório privado;
2. o resultado possuir evidência suficiente;
3. o aprendizado puder ser separado de dados operacionais;
4. a narrativa pública for reconstruída;
5. scripts selecionados forem parametrizados;
6. a auditoria de publicação passar;
7. a atualização for revisada por Pull Request.

---

## English

### Evolution overview

The public evolution is organized into five learning cycles:

| Cycle | Main outcome |
|---|---|
| Foundation and connectivity | Linux nodes, controlled networking, remote access, and inventory |
| Operational control and safety | Auditing, explicit administrative confirmation, maintenance, versioning, and restore testing |
| Distributed computing | Parallel jobs, work slicing, result aggregation, and an integrated pipeline |
| Observability and maturity | Job monitoring, metrics, queueing, log inspection, dashboards, and structured exports |
| Persistence and access | File-based storage, storage-backed visualization, and a local read-only API |

### Key engineering lessons

- Validate each layer before adding complexity.
- Keep common and privileged operations separate.
- Treat logs and exit codes as evidence.
- A backup is incomplete until restoration is tested.
- Parallel execution is not the same as divided work.
- Partial results require coverage and aggregation checks.
- Monitoring must be compared with its source data.
- Small shell input mistakes can silently truncate iteration.
- Storage and visualization should remain separate concerns.
- Read-only interfaces are safer first steps than remote-control APIs.

### Public status

This showcase currently documents historical learning through Phase 15.

The record does not claim that the physical environment is currently active. Future entries will be added only after private validation, sanitization, automated auditing, and public review.
