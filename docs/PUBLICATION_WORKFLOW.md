# Fluxo de publicação segura / Safe Publication Workflow

Este documento define como a evolução do laboratório privado é transformada em conteúdo público, sanitizado e verificável.

O repositório público é uma derivação editorial independente. Ele não é um espelho, backup, fork ou mecanismo de sincronização do ambiente operacional.

## Princípios obrigatórios

- manter histórico Git independente do repositório-fonte;
- publicar somente conceitos, padrões e artefatos explicitamente permitidos;
- tratar qualquer informação duvidosa como privada;
- substituir identificadores reais por nomes genéricos;
- usar somente dados sintéticos ou reservados para documentação;
- revisar arquivos antes de qualquer envio ao GitHub;
- nunca utilizar a vitrine pública para controlar o laboratório privado;
- nunca copiar diretórios completos, objetos Git ou checkpoints brutos.

A ausência de uma informação na lista de bloqueios não representa autorização automática para publicação.

## Classificação das informações

Cada elemento deve ser classificado antes de entrar na vitrine.

| Classe | Tratamento | Exemplos conceituais |
|---|---|---|
| Proibido | Não publicar | credenciais, chaves, tokens, endereços reais, inventários reais e logs brutos |
| Transformável | Reescrever e sanitizar | topologia, comandos, scripts, métricas e registros de evolução |
| Publicável | Revisar antes de incluir | conceitos, diagramas genéricos, documentação e exemplos sintéticos |

Quando um arquivo mistura classes diferentes, somente a parte permitida deve ser recriada publicamente.

## Fluxo por atualização

### 1. Identificar uma mudança relevante

Uma atualização pública pode ser considerada quando o laboratório privado alcançar, por exemplo:

- uma nova capacidade;
- uma melhoria arquitetural;
- uma correção com valor educacional;
- um novo padrão de automação;
- uma mudança importante no modelo operacional;
- um aprendizado que possa ser apresentado sem revelar o ambiente real.

A vitrine não precisa acompanhar cada alteração interna nem operar em tempo real.

### 2. Definir uma allowlist

Antes da edição, deve ser criada uma lista explícita dos arquivos públicos que poderão mudar.

Arquivos não incluídos na allowlist permanecem fora do escopo da atualização.

A allowlist deve indicar:

- objetivo da publicação;
- arquivos que serão criados ou modificados;
- conceitos privados utilizados como referência;
- transformações necessárias;
- validações aplicáveis.

### 3. Recriar o conteúdo

O conteúdo público deve ser escrito como um novo artefato.

Transformações esperadas incluem:

| Origem conceitual | Forma pública |
|---|---|
| nomes reais de máquinas | identificadores genéricos |
| endereços e rotas reais | valores reservados para documentação |
| usuários e caminhos pessoais | variáveis configuráveis |
| datas operacionais exatas | ordem relativa das fases |
| capacidade real de hardware | descrição qualitativa |
| inventário privado | arquivo de exemplo sintético |
| saída real de comandos | saída reduzida ou fabricada |
| script operacional | implementação genérica e parametrizada |
| checkpoint privado | resumo educacional da evolução |

Nenhuma associação reversível com o ambiente privado deve ser preservada.

### 4. Validar localmente

Antes de preparar um commit:

- conferir o conjunto completo de arquivos alterados;
- revisar o diff linha por linha;
- confirmar codificação UTF-8 sem BOM;
- confirmar finais de linha LF;
- verificar espaços finais e estrutura Markdown;
- validar a sintaxe dos scripts;
- executar a auditoria automatizada de publicação;
- procurar credenciais, identificadores e referências privadas;
- revisar links, diagramas e exemplos;
- confirmar o banner Matrix no README principal.

A auditoria automatizada complementa, mas não substitui, a revisão humana.

### Auditoria contínua no GitHub

O workflow de auditoria é executado em pushes para `main`, em Pull Requests destinados a `main` e por acionamento manual.

Ele:

- usa somente permissão de leitura;
- desabilita a persistência de credenciais;
- fixa ações externas por commit verificado;
- executa `tools/audit_publication.ps1`;
- não utiliza segredos adicionais;
- deve se tornar um check obrigatório da `main` após a primeira execução bem-sucedida.

### 5. Preparar o commit

Somente arquivos aprovados devem entrar na área de preparação.

Antes do commit:

1. comparar os arquivos preparados com a allowlist;
2. executar novamente as validações sobre o conteúdo preparado;
3. confirmar que nenhum arquivo inesperado foi incluído;
4. utilizar uma mensagem que descreva somente a evolução pública;
5. não registrar hashes, caminhos ou referências do repositório privado.

Cada commit deve representar uma mudança pública coerente e revisável.

### 6. Publicar

A publicação externa ocorre somente depois da auditoria local e da autorização explícita correspondente.

Quando aplicável:

- utilizar uma branch de trabalho dedicada;
- enviar somente a branch sanitizada;
- criar um Pull Request com resumo e validações;
- conferir a visualização final no GitHub;
- integrar apenas quando o conteúdo público estiver correto.

A criação do repositório remoto também deve ocorrer somente após a primeira auditoria integral da árvore local.

### 7. Verificar depois da publicação

Após cada publicação:

- confirmar que o commit remoto corresponde ao commit validado;
- verificar a renderização do README e do banner;
- testar links e diagramas;
- conferir a visibilidade pública;
- revisar novamente os arquivos diretamente pelo GitHub;
- confirmar que não há segredos detectados;
- verificar que um clone novo contém somente o material público esperado.

## Modelo contínuo de evolução

Cada avanço relevante do laboratório pode gerar uma atualização correspondente na vitrine, mas a relação não precisa ser individual.

Uma única atualização pública pode resumir várias mudanças privadas relacionadas.

A documentação pública deve registrar:

- a capacidade adicionada;
- o problema conceitual resolvido;
- o aprendizado obtido;
- a posição da mudança na evolução do projeto;
- as limitações que continuam válidas.

Detalhes operacionais permanecem exclusivamente no ambiente privado.

## Resposta a incidente

Se houver suspeita de exposição:

1. interromper novas publicações;
2. identificar o material afetado;
3. revogar ou rotacionar imediatamente qualquer segredo envolvido;
4. remover o conteúdo da versão pública;
5. avaliar a necessidade de reescrever o histórico;
6. verificar forks, caches, artefatos e versões publicadas;
7. registrar o incidente em local privado;
8. revisar as regras de sanitização e auditoria.

Apagar um arquivo ou commit não substitui a revogação de uma credencial exposta.

## Critério de conclusão

Uma atualização é considerada concluída somente quando:

- o conteúdo está limitado à allowlist;
- a sanitização manual foi concluída;
- a auditoria automatizada não encontrou bloqueios;
- os arquivos preparados foram conferidos;
- a publicação foi autorizada;
- o estado remoto foi verificado;
- o repositório local voltou a um estado limpo.

## English summary

Every public update is independently authored from an explicit allowlist. Private history, raw files, operational identifiers, credentials and reversible infrastructure details must never be transferred.

Potentially useful concepts are rewritten with generic names, configurable variables and synthetic examples. Local automated checks and manual review must both succeed before any commit or remote publication.

The canonical audit also runs on GitHub Actions with read-only permissions.

If exposure is suspected, publishing stops immediately. Compromised secrets are revoked or rotated before repository cleanup is treated as complete.
