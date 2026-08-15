# MLI-Knot-LAB-CLUSTER-PUBLIC — Public Showcase

> **Status:** vitrine técnica pública e sanitizada do LAB-CLUSTER.  
> **História Git:** independente da fonte operacional privada; não é espelho nem cópia direta.  
> **Publicação:** alterações públicas devem continuar passando por sanitização, auditoria e revisão.


<div align="center">

<img src="https://raw.githubusercontent.com/proftectiagocosta-hash/MLI-Knot-Mind-Showcase/main/assets/matrix-inspired-banner.gif" width="100%" alt="Matrix-inspired cyber banner for MLI-Knot LAB-CLUSTER" />

</div>

> **Evolução documentada de um laboratório físico de computação distribuída, automação e observabilidade.**
> **Documented evolution of a physical lab for distributed computing, automation, and observability.**

![Status](https://img.shields.io/badge/status-sanitized%20showcase-2563eb)
![Scope](https://img.shields.io/badge/scope-public%20curated%20layer-0f766e)
![Language](https://img.shields.io/badge/language-PT--BR%20%7C%20EN-0891b2)
![License](https://img.shields.io/badge/license-MIT-16a34a)
[![Publication audit](https://github.com/proftectiagocosta-hash/MLI-Knot-LAB-CLUSTER-PUBLIC/actions/workflows/publication-audit.yml/badge.svg)](https://github.com/proftectiagocosta-hash/MLI-Knot-LAB-CLUSTER-PUBLIC/actions/workflows/publication-audit.yml)

[Português](#português) | [English](#english)

---

## Português

### Visão geral

O **MLI-Knot LAB-CLUSTER** é um laboratório incremental criado para estudar, implementar e validar conceitos de infraestrutura Linux, administração remota, automação, processamento distribuído, métricas, armazenamento e exposição controlada de informações.

Este repositório é a **vitrine pública sanitizada** do projeto. Ele apresenta a evolução técnica, as decisões arquiteturais e exemplos selecionados sem publicar dados operacionais do ambiente físico.

O conteúdo público possui histórico Git próprio e independente. Ele não é fork, espelho ou cópia direta da fonte operacional privada.

### O que esta vitrine apresenta

- evolução consolidada dos principais marcos do laboratório;
- arquitetura conceitual com nó de controle e workers;
- exemplos parametrizados de inventário e administração remota;
- mecanismos de confirmação e registro de operações;
- progressão de tarefas simples para processamento distribuído;
- monitoramento, métricas, armazenamento e visualização;
- critérios utilizados para separar documentação pública de dados operacionais.

### Evolução em resumo

| Etapa | Aprendizado principal |
|---|---|
| Fundação | Preparação dos nós Linux e organização da rede do laboratório |
| Conectividade | Verificação de disponibilidade e administração remota |
| Inventário | Coleta automatizada de informações dos workers |
| Execução controlada | Distribuição de comandos comuns com logs por execução |
| Administração segura | Confirmação explícita e bloqueios para operações administrativas |
| Manutenção | Auditoria antes e depois de rotinas controladas |
| Processamento distribuído | Execução de jobs e divisão de trabalho entre workers |
| Pipeline | Distribuição, acompanhamento e agregação de resultados |
| Observabilidade | Métricas, resumos e dashboards textuais |
| Persistência | Exportação e armazenamento simples de resultados |
| Interface local | Consulta somente leitura por API local mínima |

A cronologia detalhada será mantida em [`docs/EVOLUTION.md`](docs/EVOLUTION.md).

### Arquitetura conceitual

| Componente | Responsabilidade pública descrita |
|---|---|
| Nó de controle | Coordenação, inventário, distribuição de comandos e consolidação |
| Workers | Execução das tarefas atribuídas e devolução de resultados |
| Inventário de exemplo | Associação entre nomes genéricos e endereços reservados para documentação |
| Camada de execução | Comunicação remota parametrizada e registro por operação |
| Camada de segurança | Confirmações, validações e bloqueios de comandos críticos |
| Camada de jobs | Filas simples, divisão de unidades e acompanhamento de estados |
| Observabilidade | Métricas, resumos, dashboards e exportações |
| Interface de consulta | Exposição local e somente leitura de informações selecionadas |

A arquitetura sanitizada será detalhada em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

### Limite entre o privado e o público

Este repositório não deve conter:

- credenciais, tokens, senhas ou chaves;
- endereços reais da infraestrutura;
- endereços físicos de interfaces de rede;
- usuários ou caminhos pessoais do ambiente operacional;
- inventários reais de equipamentos;
- logs brutos ou identificadores de execuções reais;
- configurações amplas de privilégio;
- referências que permitam reconstruir a fonte operacional privada.

Todos os exemplos públicos devem utilizar nomes genéricos, variáveis configuráveis e dados reservados para documentação.

Os critérios completos serão registrados em [`docs/SANITIZATION.md`](docs/SANITIZATION.md).

### Conteúdo público

- [`docs/EVOLUTION.md`](docs/EVOLUTION.md): linha evolutiva consolidada;
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): arquitetura pública e fluxo conceitual;
- [`docs/SANITIZATION.md`](docs/SANITIZATION.md): política de sanitização;
- [`docs/PUBLICATION_WORKFLOW.md`](docs/PUBLICATION_WORKFLOW.md): fluxo de atualização da vitrine;
- [`.github/workflows/publication-audit.yml`](.github/workflows/publication-audit.yml): executa a auditoria automática em pushes e Pull Requests;
- [`examples/cluster_hosts.example.txt`](examples/cluster_hosts.example.txt): inventário inteiramente fictício;
- `scripts/`: versões públicas, parametrizadas e revisadas dos scripts selecionados;
- `tools/audit_publication.ps1`: executa a auditoria preventiva localmente e no GitHub Actions.

### Modelo de atualização

O desenvolvimento operacional acontece primeiro no ambiente privado. Depois de cada marco validado:

1. o aprendizado com valor público é selecionado;
2. dados específicos do ambiente são substituídos por abstrações;
3. scripts escolhidos são parametrizados;
4. a árvore pública passa por auditoria automática;
5. o diff é revisado;
6. a atualização é publicada por branch e Pull Request.

A vitrine acompanha a evolução do laboratório sem transformar o repositório público em fonte operacional.

### Estado deste material

A primeira publicação consolida o aprendizado histórico até a etapa de consulta local somente leitura.

Isso não confirma que a infraestrutura física esteja atualmente ligada, acessível ou reproduzida exatamente como nos exemplos. O conteúdo deve ser tratado como material educacional e demonstração de evolução técnica.

### Uso responsável

Antes de adaptar qualquer exemplo:

- revise todos os comandos;
- use inventário próprio;
- aplique o princípio do menor privilégio;
- teste primeiro em ambiente controlado;
- mantenha logs;
- evite operações administrativas em massa;
- nunca armazene credenciais no repositório.

---

## English

### Overview

**MLI-Knot LAB-CLUSTER** is an incremental physical lab created to study and validate Linux infrastructure, remote administration, automation, distributed processing, observability, storage, and controlled information access.

This repository is the project's **sanitized public showcase**. It documents technical evolution, architectural decisions, and selected examples without exposing operational details from the physical environment.

The public repository has a fresh and independent Git history. It is not a fork, mirror, or direct copy of the private operational source.

### What is included

- a consolidated learning timeline;
- a conceptual control-node and worker architecture;
- parameterized remote inventory and execution examples;
- explicit confirmation and logging patterns;
- distributed jobs, metrics, storage, and read-only access concepts;
- a documented sanitization and publication workflow.

### Security boundary

Public examples use generic hostnames, configurable variables, and documentation-only data.

Real infrastructure addresses, hardware identifiers, usernames, credentials, raw logs, and private operational references are intentionally excluded.

### Update strategy

New work is validated privately first. Publicly useful learning is then abstracted, sanitized, audited, reviewed, and published through a dedicated Pull Request.

This repository is an educational showcase, not a production-ready cluster distribution and not evidence of the current operational state of the physical lab.

---

## Author

Created by [Tiago Costa | Tendoshk](https://github.com/proftectiagocosta-hash) as part of the **MLI-Knot / Tendoshk** ecosystem.

## License

Distributed under the [MIT License](LICENSE).
