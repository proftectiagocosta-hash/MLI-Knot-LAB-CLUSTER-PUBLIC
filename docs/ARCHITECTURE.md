# Arquitetura Pública / Public Architecture

## Português

### Objetivo

Este documento apresenta a arquitetura conceitual e sanitizada do MLI-Knot LAB-CLUSTER.

A representação descreve papéis, fluxos e responsabilidades. Ela não reproduz a topologia física, o inventário, os endereços, os usuários ou os mecanismos reais de acesso do laboratório.

### Visão geral

~~~mermaid
flowchart TD
    OP["Operador autorizado"] --> CN["Nó de controle"]
    CN --> IV["Inventário configurável"]
    CN --> EX["Camada de execução"]
    EX --> WP["Pool de workers"]
    WP --> JR["Resultados e logs"]
    JR --> OB["Observabilidade"]
    OB --> ST["Storage baseado em arquivos"]
    ST --> API["API local somente leitura"]
~~~

O nó de controle coordena o fluxo. Os workers executam tarefas atribuídas. Resultados são preservados em arquivos separados, transformados em métricas, exportados e armazenados antes de serem consultados por uma interface somente leitura.

### Camadas da arquitetura

| Camada | Responsabilidade | Limite público |
|---|---|---|
| Configuração | Receber inventário, usuário e diretórios | Somente exemplos fictícios e variáveis |
| Inventário | Definir os workers disponíveis | Nenhum inventário real versionado |
| Conectividade | Verificar disponibilidade e acesso | Nenhuma credencial incorporada |
| Execução comum | Distribuir comandos sem privilégio elevado | Comandos revisados e parametrizados |
| Administração controlada | Executar operações privilegiadas após confirmação | Nenhuma regra real de privilégio publicada |
| Jobs | Criar uma unidade rastreável de execução | Identificadores públicos são sintéticos |
| Divisão | Separar trabalho em fatias | Intervalos e cargas são exemplos |
| Agregação | Validar cobertura e recompor resultados | Nenhum resultado operacional bruto |
| Fila | Controlar estados de trabalhos pendentes e concluídos | Implementação simples e educacional |
| Observabilidade | Produzir resumos, métricas e alertas | Saídas públicas são sintéticas |
| Exportação | Gerar formatos estruturados | Nenhum export real do laboratório |
| Storage | Preservar snapshots de forma acrescentável | Apenas estrutura conceitual e exemplos |
| API | Permitir consulta local e somente leitura | Sem mutações ou execução remota |

### Componentes conceituais

#### Nó de controle

Responsável por:

- carregar a configuração;
- validar o inventário;
- verificar disponibilidade;
- iniciar comandos ou jobs;
- acompanhar execuções;
- preservar logs;
- agregar resultados;
- produzir métricas;
- gerar exportações;
- armazenar snapshots;
- disponibilizar consultas locais.

O nó de controle não transforma os workers em uma única máquina transparente. Ele coordena sistemas independentes.

#### Pool de workers

Cada worker:

- continua sendo um sistema independente;
- recebe somente a tarefa atribuída;
- produz seu próprio estado de saída;
- mantém seus próprios recursos;
- pode falhar independentemente;
- devolve resultados ao fluxo de controle.

A arquitetura não combina automaticamente memória, processadores ou armazenamento dos workers.

#### Inventário configurável

O inventário público utiliza entradas fictícias e deve ser fornecido externamente aos scripts.

Formato conceitual:

| Campo | Exemplo público |
|---|---|
| Hostname | `worker-01` |
| Endereço | reservado para documentação |
| Papel | `worker` |
| Estado inicial | desconhecido até a verificação |

O inventário não deve armazenar credenciais.

#### Camada de execução

A execução comum e a administração privilegiada permanecem separadas.

A execução comum:

- recebe um comando explícito;
- identifica cada worker;
- registra saída e código de retorno;
- não presume sucesso global quando apenas parte dos workers conclui.

A administração controlada acrescenta:

- apresentação prévia do comando;
- confirmação textual;
- bloqueios preventivos;
- logs próprios;
- interrupção diante de divergências.

Confirmação textual não substitui autorização, revisão ou menor privilégio.

### Fluxo de um job comum

1. carregar configuração;
2. validar inventário;
3. criar identificador sintético do job;
4. verificar workers;
5. distribuir a tarefa;
6. registrar um resultado por worker;
7. aguardar encerramento;
8. consolidar estados;
9. disponibilizar logs para inspeção.

### Fluxo de um job fatiado

1. receber a quantidade de unidades;
2. determinar workers disponíveis;
3. dividir o intervalo;
4. atribuir uma fatia diferente a cada worker;
5. executar em paralelo;
6. coletar resultados parciais;
7. verificar lacunas e sobreposições;
8. validar a quantidade processada;
9. agregar o resultado;
10. produzir um veredito final.

### Estados da fila

~~~mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Running
    Running --> Done
    Running --> Failed
    Failed --> Pending: nova tentativa explícita
    Done --> [*]
~~~

Uma nova tentativa nunca deve apagar a evidência da execução anterior.

### Observabilidade

A observabilidade é construída em camadas:

| Nível | Pergunta respondida |
|---|---|
| Disponibilidade | O worker pode ser alcançado? |
| Execução | O comando terminou? |
| Resultado | A saída produzida é válida? |
| Job | Todos os workers finalizaram? |
| Agregação | O resultado global está completo? |
| Histórico | Como execuções anteriores se comportaram? |
| Fila | Quais trabalhos aguardam ou falharam? |
| Dashboard | Qual é o estado consolidado? |
| Storage | Qual snapshot está preservado? |
| API | Quais informações podem ser consultadas localmente? |

Logs são evidências primárias. Métricas e dashboards são interpretações derivadas e devem permanecer comparáveis às fontes.

### Exportação e storage

A exportação transforma métricas em formatos estruturados.

O storage:

- é baseado em arquivos;
- acrescenta novos snapshots;
- mantém um índice;
- aponta para o snapshot mais recente;
- não reescreve silenciosamente snapshots anteriores;
- não substitui um banco de dados quando consultas complexas forem necessárias.

Exportar e armazenar são responsabilidades diferentes.

### API local somente leitura

A camada de API representa o limite atual da evolução histórica publicada.

Princípios:

- acesso somente local;
- leitura de dados já produzidos;
- ausência de endpoints mutáveis;
- nenhuma execução remota iniciada pela API;
- nenhuma credencial exposta;
- falha explícita quando a fonte não está disponível.

Uma futura interface web não está automaticamente autorizada a alterar esse limite.

### Variáveis públicas recomendadas

| Variável | Finalidade |
|---|---|
| `HOSTS_FILE` | Caminho do inventário configurável |
| `REMOTE_USER` | Usuário fornecido externamente |
| `LOG_DIR` | Diretório de logs |
| `JOB_ROOT` | Diretório dos jobs |
| `EXPORT_ROOT` | Diretório das exportações |
| `STORAGE_ROOT` | Diretório dos snapshots |
| `API_BIND_HOST` | Interface local de consulta |
| `API_PORT` | Porta definida pelo operador |

Nenhuma dessas variáveis deve possuir valor operacional real no repositório.

### Modelo de falhas

| Falha | Tratamento esperado |
|---|---|
| Inventário ausente | Interromper antes da execução |
| Worker inacessível | Registrar falha daquele worker |
| Falha de autenticação | Não tentar contornar silenciosamente |
| Comando malsucedido | Preservar código de saída e log |
| Resultado parcial ausente | Invalidar agregação |
| Intervalos sobrepostos | Invalidar resultado global |
| Job incompleto | Não marcar como concluído |
| Exportação inconsistente | Não enviar ao storage |
| Snapshot ausente | API deve responder com erro controlado |
| Divergência entre dashboard e fonte | Auditar a leitura antes de avançar |

### Fronteiras de segurança

| Zona | Pode conter | Não pode ser publicada |
|---|---|---|
| Repositório público | Documentação, exemplos e scripts sanitizados | Dados operacionais |
| Configuração local | Inventário e parâmetros do operador | Credenciais versionadas |
| Ambiente operacional | Máquinas, serviços, logs e resultados reais | Cópia automática para a vitrine |
| Processo de publicação | Derivação, auditoria e revisão | Sincronização sem inspeção |

### O que esta arquitetura demonstra

- administração coordenada de múltiplos sistemas;
- automação incremental;
- separação entre execução comum e privilegiada;
- jobs paralelos;
- divisão e agregação de trabalho;
- observabilidade progressiva;
- fila simples;
- persistência baseada em arquivos;
- consulta local somente leitura;
- disciplina de segurança e documentação.

### O que esta arquitetura não demonstra

- soma automática de memória ou processadores;
- sistema operacional único entre os workers;
- tolerância completa a falhas;
- scheduler de produção;
- armazenamento distribuído;
- orquestração completa;
- segurança pronta para internet;
- plataforma de produção.

### Regra de evolução

Novas camadas devem ser adicionadas somente quando:

1. a camada anterior continuar estável;
2. o problema estiver claramente definido;
3. houver critério de conclusão;
4. a validação ocorrer no ambiente privado;
5. a representação pública puder ser sanitizada;
6. a arquitetura pública for atualizada sem revelar a topologia real.

---

## English

### Overview

The public architecture represents an authorized operator, a control node, a configurable inventory, an execution layer, a worker pool, job results, observability, file-based storage, and a local read-only API.

It describes responsibilities and data flow without reproducing the physical topology or operational access configuration.

### Core principles

- Workers remain independent systems.
- The control node coordinates rather than merging hardware resources.
- Common and privileged execution paths remain separate.
- Logs and exit codes are primary evidence.
- Partial work requires coverage and aggregation validation.
- Metrics and dashboards remain traceable to their sources.
- Export and storage are separate responsibilities.
- The API reads previously produced data and does not trigger remote execution.
- Real configuration remains outside the public repository.

### Public boundary

The repository contains only sanitized documentation, fictional inventory, parameterized scripts, and publication-audit tooling. Real infrastructure data and private Git history remain outside this architecture.
