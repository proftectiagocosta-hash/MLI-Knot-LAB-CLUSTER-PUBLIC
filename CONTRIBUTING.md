# Contributing / Contribuindo

[English](#english) | [Português](#português)

Thank you for considering a contribution to the MLI-Knot LAB-CLUSTER public showcase.

Obrigado por considerar uma contribuição para a vitrine pública do MLI-Knot LAB-CLUSTER.

This repository is a sanitized, educational, independently maintained public layer. It is not the operational source of the physical lab and must never become a mirror, backup, synchronization target, or control surface for a private environment.

Este repositório é uma camada pública sanitizada, educacional e mantida de forma independente. Ele não é a fonte operacional do laboratório físico e nunca deve se tornar espelho, backup, destino de sincronização ou superfície de controle de um ambiente privado.

---

## English

### Public repository boundary

Every contribution must preserve these invariants:

- the Git history remains independent from any private operational source;
- public material is recreated or deliberately adapted inside this repository;
- examples use fictional, synthetic, generic, or documentation-only data;
- scripts are parameterized and do not contain embedded operational targets;
- publication is limited to an explicit file allowlist;
- automated auditing complements, but never replaces, human review;
- uncertain information remains private.

A contribution may be technically useful and still be rejected when it weakens the public boundary.

### Suitable contributions

Examples of contributions that may fit this repository include:

- corrections to public documentation;
- clearer architectural explanations;
- improvements to the documented evolution of the lab;
- fully fictional inventory examples;
- safer or clearer parameterized scripts;
- improvements to the publication audit;
- accessibility or readability improvements;
- corrections to links, formatting, or bilingual consistency;
- security fixes affecting only the public surface;
- educational examples that can be understood without operational data.

### Content that must not be submitted

Do not add, quote, attach, or preserve:

- passwords, tokens, private keys, recovery phrases, session data, or authentication files;
- real infrastructure addresses, routes, hostnames, usernames, or access methods;
- physical interface identifiers or hardware serial information;
- personal or absolute paths from an operational machine;
- real equipment inventories or capacity records tied to identifiable systems;
- raw logs, command output, screenshots, recordings, or exports from the lab;
- database files, service state, backups, checkpoints, or unrevised reports;
- private repository names, remotes, commit identifiers, branches, tags, or Git metadata;
- files copied directly from a private working tree;
- combinations of individually harmless details that could reveal a private topology;
- instructions for unauthorized administration, privilege abuse, credential collection, persistence, evasion, or destructive activity.

Removing a password or token does not automatically make a file safe for publication.

### Independent history requirement

Create all contribution branches from the current public repository.

Do not:

- create a public branch from a private commit;
- import private commits;
- attach a private source as a remote;
- copy a private `.git` directory;
- transplant raw private history;
- publish a branch that contains files later deleted from the visible diff.

A clean final tree does not erase sensitive material from earlier commits.

### Define the allowlist before editing

Before changing files, write down the exact public scope:

- purpose of the contribution;
- files to create or modify;
- public concepts being documented;
- sanitization transformations required;
- validation applicable to each file;
- anything explicitly outside the contribution.

Only files in that allowlist belong in the branch. Do not add unrelated cleanup or silently expand the scope during review.

The repository audit contains a canonical tree allowlist. A new tracked path requires an intentional, reviewed update to that list in `tools/audit_publication.ps1`.

### Sanitizing material

Public material should be newly written or carefully adapted. Typical transformations include:

- real machine names become generic roles such as `control-node` or `worker-01`;
- users and paths become configurable variables;
- real command output becomes a small synthetic example;
- exact operational dates become relative milestones or clearly fictional dates;
- private inventory becomes a minimal fictional inventory;
- authentication details become high-level principles;
- operational scripts become reduced, parameterized, privilege-aware examples;
- private checkpoints become consolidated educational narratives.

Use only documentation-reserved network values when an address is necessary. Do not imply that an example represents an active topology.

### Public script requirements

A submitted public script must, when applicable:

- accept targets, users, paths, and modes through explicit parameters or variables;
- avoid embedded real destinations;
- avoid personal fixed paths;
- use strict error handling;
- fail visibly instead of hiding errors;
- use least privilege;
- avoid disabling host verification or other security controls;
- default to preview or read-only behavior when practical;
- require explicit confirmation before administrative execution;
- document assumptions, risks, and limitations;
- use only fictional examples;
- operate only on systems the user is authorized to administer.

Do not weaken the publication audit merely to make a contribution pass.

### Local validation

Before committing, inspect the complete changed-file list and review the diff line by line.

Run the canonical audit from the repository root:

```powershell
pwsh ./tools/audit_publication.ps1
```

The audit checks the public tree, encoding, line endings, Markdown structure, sensitive patterns, documentation-only addressing, script policy, syntax, Git modes, and other repository invariants.

Also perform validations relevant to the change, such as:

- Markdown rendering and links;
- Portuguese and English consistency;
- Bash syntax for shell scripts;
- PowerShell syntax for audit changes;
- safe defaults and confirmation behavior;
- fictional inventory format;
- absence of private data in screenshots or attachments.

State any test that could not be performed. Do not represent an unexecuted check as completed.

### Branches, commits, and Pull Requests

Use a focused branch created from the current `main` branch.

Keep commits coherent and reviewable. Do not mix unrelated documentation, script, workflow, formatting, and policy changes unless they form one necessary publication unit.

A Pull Request should explain:

- what changed;
- why it belongs in the public showcase;
- the exact file allowlist;
- how private concepts were transformed;
- security and privacy implications;
- validation performed;
- audit result;
- known limitations or untested environments;
- whether the canonical tree allowlist changed.

The required `publication-audit` check must pass before integration. A successful automated check does not remove the need to inspect the final diff manually.

### Suspected exposure

Do not reproduce suspected sensitive material in a public issue, Pull Request comment, review, discussion, or attachment.

Follow [`SECURITY.md`](SECURITY.md). Use GitHub private vulnerability reporting when available, or contact the maintainer through a private channel listed on the maintainer profile.

Describe only the affected path and the general category of risk until a private channel is established.

### License and attribution

By submitting a contribution, you agree that it may be distributed under the repository's MIT License.

Preserve existing copyright, license, notice, and attribution information. Include third-party material only when its license permits publication and the required attribution is documented.

### Review expectations

Submission does not guarantee acceptance, publication, inclusion in a release, or a fixed review deadline.

A contribution may be revised or declined because of sanitization, public scope, safety, licensing, maintainability, accuracy, audit results, or project direction.

---

## Português

### Limite do repositório público

Toda contribuição deve preservar estes invariantes:

- o histórico Git permanece independente de qualquer fonte operacional privada;
- o material público é recriado ou deliberadamente adaptado dentro deste repositório;
- os exemplos utilizam dados fictícios, sintéticos, genéricos ou exclusivos para documentação;
- os scripts são parametrizados e não contêm alvos operacionais embutidos;
- a publicação fica limitada a uma allowlist explícita de arquivos;
- a auditoria automatizada complementa, mas nunca substitui, a revisão humana;
- informações duvidosas permanecem privadas.

Uma contribuição pode ser tecnicamente útil e ainda assim ser recusada quando enfraquecer o limite público.

### Contribuições adequadas

Exemplos de contribuições que podem ser adequadas a este repositório:

- correções na documentação pública;
- explicações arquiteturais mais claras;
- melhorias na evolução documentada do laboratório;
- exemplos de inventário inteiramente fictícios;
- scripts parametrizados mais seguros ou claros;
- melhorias na auditoria de publicação;
- melhorias de acessibilidade ou legibilidade;
- correções de links, formatação ou consistência bilíngue;
- correções de segurança limitadas à superfície pública;
- exemplos educacionais compreensíveis sem dados operacionais.

### Conteúdo que não deve ser enviado

Não adicione, cite, anexe ou preserve:

- senhas, tokens, chaves privadas, frases de recuperação, dados de sessão ou arquivos de autenticação;
- endereços, rotas, hostnames, usuários ou métodos reais de acesso à infraestrutura;
- identificadores físicos de interfaces ou números de série de hardware;
- caminhos pessoais ou absolutos de uma máquina operacional;
- inventários reais de equipamentos ou capacidades ligadas a sistemas identificáveis;
- logs, saídas de comandos, capturas, gravações ou exportações reais do laboratório;
- bancos de dados, estados de serviço, backups, checkpoints ou relatórios não revisados;
- nomes de repositórios privados, remotes, commits, branches, tags ou metadados Git privados;
- arquivos copiados diretamente de uma árvore de trabalho privada;
- combinações de detalhes aparentemente inofensivos que permitam inferir uma topologia privada;
- instruções para administração não autorizada, abuso de privilégio, coleta de credenciais, persistência, evasão ou atividade destrutiva.

Remover uma senha ou um token não torna um arquivo automaticamente seguro para publicação.

### Exigência de histórico independente

Crie todas as branches de contribuição a partir do repositório público atual.

Não:

- crie uma branch pública a partir de um commit privado;
- importe commits privados;
- adicione uma fonte privada como remote;
- copie um diretório `.git` privado;
- transplante histórico privado bruto;
- publique uma branch que contenha arquivos sensíveis depois removidos do diff visível.

Uma árvore final limpa não apaga material sensível de commits anteriores.

### Defina a allowlist antes da edição

Antes de alterar arquivos, registre o escopo público exato:

- objetivo da contribuição;
- arquivos que serão criados ou modificados;
- conceitos públicos documentados;
- transformações de sanitização necessárias;
- validações aplicáveis a cada arquivo;
- tudo que permanece explicitamente fora da contribuição.

Somente arquivos presentes nessa allowlist pertencem à branch. Não inclua limpeza sem relação nem amplie silenciosamente o escopo durante a revisão.

A auditoria do repositório mantém uma allowlist canônica da árvore. Um novo caminho versionado exige atualização intencional e revisada dessa lista em `tools/audit_publication.ps1`.

### Sanitização do material

O material público deve ser escrito novamente ou adaptado com cuidado. Transformações comuns incluem:

- nomes reais de máquinas tornam-se papéis genéricos, como `control-node` ou `worker-01`;
- usuários e caminhos tornam-se variáveis configuráveis;
- saídas reais de comandos tornam-se pequenos exemplos sintéticos;
- datas operacionais exatas tornam-se marcos relativos ou datas claramente fictícias;
- inventários privados tornam-se inventários fictícios mínimos;
- detalhes de autenticação tornam-se princípios de alto nível;
- scripts operacionais tornam-se exemplos reduzidos, parametrizados e conscientes de privilégio;
- checkpoints privados tornam-se narrativas educacionais consolidadas.

Use somente valores reservados para documentação quando um endereço for necessário. Não indique que um exemplo representa uma topologia ativa.

### Requisitos para scripts públicos

Um script público enviado deve, quando aplicável:

- receber alvos, usuários, caminhos e modos por parâmetros ou variáveis explícitas;
- evitar destinos reais embutidos;
- evitar caminhos pessoais fixos;
- utilizar tratamento estrito de erros;
- falhar de forma visível em vez de ocultar erros;
- aplicar o menor privilégio;
- evitar desativar verificação de host ou outros controles de segurança;
- adotar modo de prévia ou somente leitura como padrão quando for viável;
- exigir confirmação explícita antes de execução administrativa;
- documentar premissas, riscos e limitações;
- utilizar apenas exemplos fictícios;
- operar somente em sistemas que o usuário esteja autorizado a administrar.

Não enfraqueça a auditoria de publicação apenas para fazer uma contribuição ser aprovada.

### Validação local

Antes do commit, confira a lista completa de arquivos alterados e revise o diff linha por linha.

Execute a auditoria canônica a partir da raiz do repositório:

```powershell
pwsh ./tools/audit_publication.ps1
```

A auditoria verifica a árvore pública, codificação, finais de linha, estrutura Markdown, padrões sensíveis, endereçamento exclusivo para documentação, políticas dos scripts, sintaxe, modos Git e outros invariantes do repositório.

Execute também as validações relevantes para a alteração, como:

- renderização Markdown e links;
- consistência entre português e inglês;
- sintaxe Bash para scripts shell;
- sintaxe PowerShell para mudanças na auditoria;
- padrões seguros e comportamento de confirmação;
- formato do inventário fictício;
- ausência de dados privados em capturas ou anexos.

Declare qualquer teste que não tenha sido executado. Não apresente uma verificação não realizada como concluída.

### Branches, commits e Pull Requests

Utilize uma branch focada, criada a partir do estado atual da `main`.

Mantenha commits coerentes e revisáveis. Não misture alterações sem relação de documentação, scripts, workflows, formatação e políticas, exceto quando formarem uma única unidade necessária de publicação.

Um Pull Request deve explicar:

- o que mudou;
- por que a mudança pertence à vitrine pública;
- a allowlist exata de arquivos;
- como conceitos privados foram transformados;
- implicações de segurança e privacidade;
- validações realizadas;
- resultado da auditoria;
- limitações conhecidas ou ambientes não testados;
- indicação de alteração da allowlist canônica da árvore.

O check obrigatório `publication-audit` deve ser aprovado antes da integração. Uma auditoria automática aprovada não elimina a necessidade de revisar manualmente o diff final.

### Suspeita de exposição

Não reproduza material possivelmente sensível em issue pública, comentário de Pull Request, revisão, discussão ou anexo.

Siga [`SECURITY.md`](SECURITY.md). Utilize o relato privado de vulnerabilidade do GitHub quando estiver disponível ou contate o responsável por um canal privado listado no perfil dele.

Informe apenas o caminho afetado e a categoria geral do risco até que exista um canal privado estabelecido.

### Licença e atribuição

Ao enviar uma contribuição, você concorda que ela poderá ser distribuída sob a Licença MIT do repositório.

Preserve informações existentes de direitos autorais, licença, aviso e atribuição. Inclua material de terceiros somente quando a licença permitir a publicação e a atribuição necessária estiver documentada.

### Expectativas de revisão

O envio não garante aceitação, publicação, inclusão em release ou prazo fixo de revisão.

Uma contribuição pode ser revisada ou recusada por questões de sanitização, escopo público, segurança, licença, manutenção, precisão, resultado da auditoria ou direção do projeto.
