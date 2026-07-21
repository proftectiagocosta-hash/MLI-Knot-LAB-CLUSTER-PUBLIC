# Security Policy

## Português

### Escopo

Este repositório é uma vitrine pública sanitizada do MLI-Knot LAB-CLUSTER.

Ele contém documentação educacional, dados fictícios e exemplos parametrizados. Não é a fonte operacional do laboratório físico e não deve receber cópias diretas de arquivos privados.

A política se aplica à branch principal, às branches de contribuição, aos Pull Requests, às releases e a qualquer artefato produzido a partir deste repositório.

### Regra fundamental

Nenhum conteúdo deve ser publicado apenas porque uma senha ou um token foi removido.

A sanitização também deve eliminar ou substituir:

- endereços reais da infraestrutura;
- identificadores físicos de interfaces;
- hostnames operacionais;
- usuários reais de acesso remoto;
- caminhos pessoais ou absolutos do ambiente;
- inventários reais de equipamentos;
- logs brutos;
- datas e identificadores de execuções reais quando puderem revelar contexto operacional;
- referências internas a repositórios privados;
- hashes ou metadados que permitam reconstruir a origem privada;
- configurações reais de autenticação ou privilégio;
- qualquer combinação de dados que permita inferir a topologia privada.

### Conteúdo proibido

Não devem ser adicionados:

- senhas;
- tokens de acesso;
- chaves privadas;
- frases de recuperação;
- cookies de sessão;
- arquivos de ambiente reais;
- credenciais de provedores;
- arquivos de autenticação SSH;
- inventários operacionais;
- backups de configuração;
- bancos de dados ou estados de execução;
- logs coletados diretamente do laboratório;
- checkpoints privados brutos;
- exportações não revisadas;
- histórico Git proveniente da fonte privada.

O `.gitignore` reduz o risco de inclusão acidental, mas não constitui uma barreira de segurança. Todo conteúdo preparado para publicação deve ser auditado.

### Dados permitidos nos exemplos

Os exemplos públicos podem utilizar:

- hostnames genéricos, como `control-node` e `worker-01`;
- usuários representados por variáveis, como `REMOTE_USER`;
- caminhos baseados em variáveis, como `$HOME`;
- redes reservadas exclusivamente para documentação;
- resultados sintéticos;
- datas fictícias claramente identificadas;
- valores de capacidade aproximados e não vinculados ao ambiente real;
- comandos parametrizados que exijam configuração consciente pelo usuário.

### Histórico independente

Este repositório deve manter histórico Git próprio.

É proibido:

- transformar o repositório público em fork da fonte privada;
- adicionar a fonte privada como remote;
- copiar o diretório `.git` da fonte;
- importar commits privados;
- publicar branches criadas a partir do histórico privado;
- confiar apenas na remoção posterior de arquivos sensíveis.

As atualizações públicas devem ser recriadas ou adaptadas em branches originadas exclusivamente deste repositório.

### Processo obrigatório antes da publicação

Toda atualização deve seguir estas etapas:

1. selecionar somente o aprendizado com valor público;
2. recriar ou adaptar o conteúdo dentro do repositório público;
3. substituir dados operacionais por exemplos;
4. executar a auditoria automatizada;
5. revisar todos os arquivos alterados;
6. revisar o diff preparado para commit;
7. confirmar que o histórico continua independente;
8. publicar por branch e Pull Request;
9. integrar somente após a validação final.

### Comunicação de uma possível exposição

Se você identificar uma possível credencial, dado pessoal ou detalhe operacional neste repositório:

1. não reproduza o conteúdo em uma issue pública;
2. não copie o valor para comentários ou discussões;
3. utilize o recurso privado de relato de vulnerabilidade do GitHub, quando disponível;
4. caso esse recurso não esteja disponível, procure um canal privado indicado no [perfil do responsável](https://github.com/proftectiagocosta-hash);
5. informe apenas o caminho afetado e a natureza geral do risco até existir um canal privado.

### Resposta a incidente

Se material sensível for confirmado:

1. interromper novas publicações;
2. considerar a credencial ou identificador comprometido;
3. revogar ou substituir credenciais afetadas;
4. remover o conteúdo da árvore pública;
5. avaliar e limpar todo o histórico público afetado;
6. revisar forks, releases, artifacts e caches aplicáveis;
7. executar novamente a auditoria completa;
8. registrar a correção sem republicar o valor sensível.

A simples exclusão no commit mais recente não remove dados de commits anteriores.

### Limitações dos exemplos

Os scripts públicos são educacionais e devem ser revisados antes de qualquer uso.

Eles não garantem:

- compatibilidade com uma distribuição específica;
- adequação a ambientes de produção;
- segurança de uma configuração não revisada;
- recuperação automática após falhas;
- proteção contra todo comando perigoso;
- autorização para administrar sistemas de terceiros.

Use os exemplos apenas em equipamentos e ambientes nos quais você possui autorização.

---

## English

### Scope

This repository is a sanitized public showcase of MLI-Knot LAB-CLUSTER.

It contains educational documentation, fictional data, and parameterized examples. It is not the operational source of the physical lab and must not receive direct copies of private files.

### Public security boundary

The public repository must exclude more than passwords and tokens. Real infrastructure addresses, hardware identifiers, operational hostnames, usernames, personal paths, raw logs, private inventory, authentication settings, source-repository references, and reconstructable private metadata are also outside the public boundary.

### Independent history

This repository must keep a fresh and independent Git history. It must not become a fork or mirror of the private source, import private commits, reuse private branches, or copy a private `.git` directory.

### Publication gate

Every public update must be selected, abstracted, sanitized, automatically audited, manually reviewed, and published through a dedicated Pull Request.

### Reporting

Do not publish suspected sensitive material in a public issue. Use GitHub private vulnerability reporting when available, or contact the maintainer through a private channel listed on the [GitHub profile](https://github.com/proftectiagocosta-hash).

### Responsible use

The public scripts are educational examples. Review and adapt them before use, apply least privilege, test in a controlled environment, and operate only systems you are authorized to administer.
