[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:AuditErrors = [System.Collections.Generic.List[string]]::new()

function Add-AuditError {
    param([Parameter(Mandatory)][string]$Message)

    [void]$script:AuditErrors.Add($Message)
    Write-Host "[audit][erro] $Message"
}

function Write-AuditOk {
    param([Parameter(Mandatory)][string]$Message)

    Write-Host "[audit][ok] $Message"
}

$repoRoot = (
    Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
).Path

$gitRootOutput = @(
    git -C $repoRoot rev-parse --show-toplevel 2>$null
)

if ($LASTEXITCODE -ne 0 -or $gitRootOutput.Count -ne 1) {
    throw "não foi possível identificar a raiz Git"
}

$gitRoot = (
    Resolve-Path -LiteralPath ([string]$gitRootOutput[0])
).Path

if ($gitRoot -ne $repoRoot) {
    throw "a ferramenta não está na árvore Git esperada"
}

if ((Split-Path -Leaf $repoRoot) -ne "MLI-Knot-LAB-CLUSTER-PUBLIC") {
    throw "nome de repositório inesperado"
}

$expectedFiles = @(
    ".gitattributes"
    ".github/workflows/publication-audit.yml"
    ".gitignore"
    "LICENSE"
    "README.md"
    "SECURITY.md"
    "docs/ARCHITECTURE.md"
    "docs/EVOLUTION.md"
    "docs/PUBLICATION_WORKFLOW.md"
    "docs/SANITIZATION.md"
    "examples/cluster_hosts.example.txt"
    "scripts/cluster_audit.sh"
    "scripts/cluster_check.sh"
    "scripts/cluster_run.sh"
    "scripts/cluster_sudo_run.sh"
    "tools/audit_publication.ps1"
)

$workflowPath = ".github/workflows/publication-audit.yml"
$trustedCheckoutPin = (
    "3d3c42e5aac5ba805825" +
    "da76410c181273ba90b1"
)

$fileMap = @{}

$diskFiles = @(
    Get-ChildItem `
        -LiteralPath $repoRoot `
        -File `
        -Recurse `
        -Force
)

foreach ($item in $diskFiles) {
    $relative = $item.FullName.Substring($repoRoot.Length)
    $relative = ($relative -replace '^[\\/]+', '') -replace '\\', '/'

    if (
        $relative -eq ".git" -or
        $relative.StartsWith(
            ".git/",
            [System.StringComparison]::OrdinalIgnoreCase
        )
    ) {
        continue
    }

    if ($fileMap.ContainsKey($relative)) {
        Add-AuditError "caminho duplicado detectado: $relative"
        continue
    }

    $fileMap[$relative] = $item
}

$actualFiles = @($fileMap.Keys | Sort-Object)

$treeDifferences = @(
    Compare-Object `
        ($expectedFiles | Sort-Object) `
        $actualFiles
)

foreach ($difference in $treeDifferences) {
    if ($difference.SideIndicator -eq "<=") {
        Add-AuditError "arquivo obrigatório ausente: $($difference.InputObject)"
    }
    else {
        Add-AuditError "arquivo fora da allowlist: $($difference.InputObject)"
    }
}

if ($treeDifferences.Count -eq 0) {
    Write-AuditOk "árvore limitada aos $($expectedFiles.Count) arquivos permitidos"
}

$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$textCache = @{}

foreach ($relative in $expectedFiles) {
    if (-not $fileMap.ContainsKey($relative)) {
        continue
    }

    $item = $fileMap[$relative]

    if (
        ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
    ) {
        Add-AuditError "link ou reparse point não permitido: $relative"
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($item.FullName)

    if (
        $bytes.Length -ge 3 -and
        $bytes[0] -eq 0xEF -and
        $bytes[1] -eq 0xBB -and
        $bytes[2] -eq 0xBF
    ) {
        Add-AuditError "BOM UTF-8 encontrado: $relative"
    }

    try {
        $text = $utf8Strict.GetString($bytes)
    }
    catch {
        Add-AuditError "conteúdo não é UTF-8 válido: $relative"
        continue
    }

    $textCache[$relative] = $text

    if ($text.Contains("`r")) {
        Add-AuditError "final de linha diferente de LF: $relative"
    }

    if ($text.IndexOf([char]0) -ge 0) {
        Add-AuditError "byte nulo encontrado: $relative"
    }

    if ($text.Length -eq 0 -or -not $text.EndsWith("`n")) {
        Add-AuditError "arquivo sem newline final: $relative"
    }

    if ([regex]::IsMatch($text, '(?m)[ \t]+$')) {
        Add-AuditError "espaço final encontrado: $relative"
    }
}

Write-AuditOk "codificação, LF e espaços finais analisados"

$sensitivePatterns = [ordered]@{
    "token do GitHub" =
        '(?i)\b(?:gh[opsu]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,})\b'

    "chave de provedor" =
        '(?:\bAKIA[0-9A-Z]{16}\b|\bAIza[0-9A-Za-z_-]{20,}\b)'

    "token Slack" =
        '(?i)\bxox[baprs]-[A-Za-z0-9-]{10,}\b'

    "JWT" =
        '\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b'

    "chave privada" =
        '-----BEGIN (?:RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----'

    "cabeçalho de autorização" =
        '(?im)authorization:[ \t]*(?:bearer|basic)[ \t]+\S+'

    "atribuição de credencial" =
        '(?im)\b(?:password|passwd|token|secret|api[_-]?key|access[_-]?key)\b[ \t]*[:=][ \t]*\S{8,}'

    "caminho home pessoal" =
        '(?i)/home/[a-z0-9._-]+(?:/|$)'

    "perfil pessoal do Windows" =
        '(?i)[A-Z]:\\Users\\[^\\\r\n]+'

    "endereço MAC" =
        '(?i)(?<![0-9a-f])(?:[0-9a-f]{2}:){5}[0-9a-f]{2}(?![0-9a-f])'

    "hash operacional ou commit" =
        '(?i)(?<![0-9a-f])[0-9a-f]{40,64}(?![0-9a-f])'
}

$privateRepoStem = "MLI-Knot-LAB-" + "CLUSTER"
$privateRepoPattern = [regex]::Escape($privateRepoStem) + '(?!-PUBLIC)'

$ipv4Pattern =
    '(?<![0-9.])(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?![0-9.])'

foreach ($relative in @($textCache.Keys)) {
    $text = [string]$textCache[$relative]

    foreach ($entry in $sensitivePatterns.GetEnumerator()) {
        $textToScan = $text

        if (
            $entry.Key -eq "hash operacional ou commit" -and
            $relative -eq $workflowPath
        ) {
            $textToScan = $textToScan.Replace($trustedCheckoutPin, "")
        }

        if ([regex]::IsMatch($textToScan, [string]$entry.Value)) {
            Add-AuditError "$($entry.Key) potencial encontrado em $relative"
        }
    }

    if (
        [regex]::IsMatch(
            $text,
            $privateRepoPattern,
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )
    ) {
        Add-AuditError "referência ao repositório-fonte encontrada em $relative"
    }

    $blockedAddressFound = $false

    foreach ($match in [regex]::Matches($text, $ipv4Pattern)) {
        $parts = @(
            $match.Value.Split(".") |
                ForEach-Object { [int]$_ }
        )

        $validOctets = (
            $parts.Count -eq 4 -and
            @($parts | Where-Object { $_ -lt 0 -or $_ -gt 255 }).Count -eq 0
        )

        $allowedAddress = (
            $validOctets -and (
                $match.Value -eq "0.0.0.0" -or
                $parts[0] -eq 127 -or
                (
                    $parts[0] -eq 192 -and
                    $parts[1] -eq 0 -and
                    $parts[2] -eq 2
                ) -or
                (
                    $parts[0] -eq 198 -and
                    $parts[1] -eq 51 -and
                    $parts[2] -eq 100
                ) -or
                (
                    $parts[0] -eq 203 -and
                    $parts[1] -eq 0 -and
                    $parts[2] -eq 113
                )
            )
        )

        if (-not $allowedAddress) {
            $blockedAddressFound = $true
            break
        }
    }

    if ($blockedAddressFound) {
        Add-AuditError "IPv4 fora das faixas públicas permitidas em $relative"
    }
}

if ($textCache.ContainsKey($workflowPath)) {
    $workflowText = [string]$textCache[$workflowPath]
    $checkoutReference = "uses: actions/checkout@$trustedCheckoutPin"
    $checkoutCount = [regex]::Matches(
        $workflowText,
        [regex]::Escape($checkoutReference)
    ).Count
    $usesCount = [regex]::Matches(
        $workflowText,
        '(?m)^[ \t]*uses:[ \t]*\S+[ \t]*$'
    ).Count

    if ($checkoutCount -ne 1 -or $usesCount -ne 1) {
        Add-AuditError "workflow deve usar somente o checkout fixado"
    }

    if (-not $workflowText.Contains("permissions:`n  contents: read`n")) {
        Add-AuditError "workflow sem permissão global somente leitura"
    }

    if (-not $workflowText.Contains("persist-credentials: false")) {
        Add-AuditError "workflow mantém credenciais após o checkout"
    }

    $auditRunReference = "run: ./tools/audit_publication.ps1"
    $auditRunCount = [regex]::Matches(
        $workflowText,
        [regex]::Escape($auditRunReference)
    ).Count
    $runCount = [regex]::Matches(
        $workflowText,
        '(?m)^[ \t]*run:[ \t]*\S.*$'
    ).Count

    if ($auditRunCount -ne 1 -or $runCount -ne 1) {
        Add-AuditError "workflow deve executar somente a auditoria canônica"
    }

    if (
        [regex]::IsMatch(
            $workflowText,
            '(?im)^[ \t]*(?:pull_request_target|workflow_run):'
        )
    ) {
        Add-AuditError "gatilho privilegiado não permitido no workflow"
    }

    if (
        [regex]::IsMatch(
            $workflowText,
            '(?im)^[ \t]*(?:permissions:[ \t]*write-all|[a-z-]+:[ \t]*write)[ \t]*$'
        )
    ) {
        Add-AuditError "permissão de escrita não permitida no workflow"
    }
}

Write-AuditOk "padrões sensíveis e endereços analisados"

$markdownFiles = @(
    $expectedFiles | Where-Object { $_.EndsWith(".md") }
)

foreach ($relative in $markdownFiles) {
    if (-not $textCache.ContainsKey($relative)) {
        continue
    }

    $text = [string]$textCache[$relative]

    $backtickFences = [regex]::Matches(
        $text,
        '(?m)^[ \t]*```'
    ).Count

    $tildeFences = [regex]::Matches(
        $text,
        '(?m)^[ \t]*~~~'
    ).Count

    if (($backtickFences % 2) -ne 0) {
        Add-AuditError "cercas com backticks desequilibradas em $relative"
    }

    if (($tildeFences % 2) -ne 0) {
        Add-AuditError "cercas com til em número ímpar em $relative"
    }
}

if ($textCache.ContainsKey("README.md")) {
    $readme = [string]$textCache["README.md"]

    $canonicalBanner =
        "https://raw.githubusercontent.com/proftectiagocosta-hash/" +
        "mli-knot-mind-public/main/assets/" +
        "matrix-inspired-banner.gif"

    $bannerCount = [regex]::Matches(
        $readme,
        [regex]::Escape($canonicalBanner)
    ).Count

    if ($bannerCount -ne 1) {
        Add-AuditError "o banner Matrix canônico deve aparecer exatamente uma vez"
    }

    $readmeLines = @($readme -split "`n")
    $meaningfulLines = @(
        $readmeLines | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        }
    )

    if (
        $meaningfulLines.Count -eq 0 -or
        -not $meaningfulLines[0].StartsWith("# ")
    ) {
        Add-AuditError "o README principal deve começar com um título"
    }

    $bannerLine = -1

    for ($index = 0; $index -lt $readmeLines.Count; $index++) {
        if ($readmeLines[$index].Contains($canonicalBanner)) {
            $bannerLine = $index
            break
        }
    }

    if ($bannerLine -lt 0 -or $bannerLine -gt 14) {
        Add-AuditError "o banner Matrix deve permanecer no início do README"
    }
}

Write-AuditOk "Markdown e banner Matrix analisados"

if ($textCache.ContainsKey("examples/cluster_hosts.example.txt")) {
    $inventory = [string]$textCache["examples/cluster_hosts.example.txt"]

    $activeHosts = @(
        ($inventory -split "`n") |
            ForEach-Object { $_.Trim() } |
            Where-Object {
                $_ -ne "" -and
                -not $_.StartsWith("#")
            }
    )

    if ($activeHosts.Count -eq 0) {
        Add-AuditError "inventário público sem alvos sintéticos"
    }

    foreach ($hostEntry in $activeHosts) {
        if (
            $hostEntry -notmatch
            '^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.example\.invalid$'
        ) {
            Add-AuditError "entrada não sintética no inventário público"
            break
        }
    }

    $uniqueHosts = @($activeHosts | Sort-Object -Unique)

    if ($uniqueHosts.Count -ne $activeHosts.Count) {
        Add-AuditError "entrada duplicada no inventário público"
    }
}

Write-AuditOk "inventário público analisado"

$shellScripts = @(
    $expectedFiles | Where-Object { $_.EndsWith(".sh") }
)

$unsafeShellConstructs = @(
    "StrictHostKeyChecking=no"
    "UserKnownHostsFile=/dev/null"
    "PasswordAuthentication=yes"
    "sshpass"
    "sudo -S"
    "eval "
)

foreach ($relative in $shellScripts) {
    if (-not $textCache.ContainsKey($relative)) {
        continue
    }

    $scriptText = [string]$textCache[$relative]

    if (-not $scriptText.StartsWith("#!/usr/bin/env bash`n")) {
        Add-AuditError "shebang Bash ausente ou inválido em $relative"
    }

    if (-not $scriptText.Contains("set -Eeuo pipefail")) {
        Add-AuditError "modo Bash estrito ausente em $relative"
    }

    if (-not $scriptText.Contains("-o BatchMode=yes")) {
        Add-AuditError "autenticação SSH interativa não foi bloqueada em $relative"
    }

    if (-not $scriptText.Contains("-o StrictHostKeyChecking=yes")) {
        Add-AuditError "verificação de host SSH ausente em $relative"
    }

    foreach ($unsafe in $unsafeShellConstructs) {
        if ($scriptText.Contains($unsafe)) {
            Add-AuditError "construção shell insegura encontrada em $relative"
        }
    }
}

foreach ($relative in @(
    "scripts/cluster_run.sh"
    "scripts/cluster_sudo_run.sh"
)) {
    if (
        $textCache.ContainsKey($relative) -and
        -not ([string]$textCache[$relative]).Contains(
            'RUN_MODE="${RUN_MODE:-preview}"'
        )
    ) {
        Add-AuditError "modo preview não é o padrão em $relative"
    }
}

if (
    $textCache.ContainsKey("scripts/cluster_run.sh") -and
    -not ([string]$textCache["scripts/cluster_run.sh"]).Contains(
        'CONFIRM_REMOTE_EXECUTION=YES'
    )
) {
    Add-AuditError "confirmação explícita ausente no executor remoto"
}

if ($textCache.ContainsKey("scripts/cluster_sudo_run.sh")) {
    $privilegedScript =
        [string]$textCache["scripts/cluster_sudo_run.sh"]

    if (-not $privilegedScript.Contains(
        'CONFIRM_PRIVILEGED_EXECUTION=YES'
    )) {
        Add-AuditError "confirmação privilegiada explícita ausente"
    }

    if ($privilegedScript.Contains("COMMAND_FILE=")) {
        Add-AuditError "executor privilegiado aceita arquivo arbitrário"
    }

    if (-not $privilegedScript.Contains(
        'exec sudo -n -- "$helper" "$action"'
    )) {
        Add-AuditError "invocação privilegiada controlada ausente"
    }
}

$bashCandidates = [System.Collections.Generic.List[string]]::new()
$candidateSet = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
$isWindows = (
    [System.Environment]::OSVersion.Platform -eq
    [System.PlatformID]::Win32NT
)

if ($isWindows) {
    $gitCommand = Get-Command git.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($null -ne $gitCommand -and $gitCommand.Path) {
        $gitDirectory = Split-Path -Parent $gitCommand.Path
        $gitInstallRoot = Split-Path -Parent $gitDirectory

        foreach ($relative in @("bin/bash.exe", "usr/bin/bash.exe")) {
            $candidate = Join-Path $gitInstallRoot $relative

            if (
                (Test-Path -LiteralPath $candidate -PathType Leaf) -and
                $candidateSet.Add($candidate)
            ) {
                $bashCandidates.Add($candidate)
            }
        }
    }
}
else {
    foreach ($command in @(Get-Command bash -All -ErrorAction SilentlyContinue)) {
        $candidate = $command.Definition

        if ($candidate -and $candidateSet.Add($candidate)) {
            $bashCandidates.Add($candidate)
        }
    }
}

$bashExecutable = $null

foreach ($candidate in $bashCandidates) {
    $candidateExitCode = 1

    try {
        & $candidate --version *> $null
        $candidateExitCode = $LASTEXITCODE
    }
    catch {
        $candidateExitCode = 1
    }

    if ($candidateExitCode -eq 0) {
        $bashExecutable = $candidate
        break
    }
}

if ($null -eq $bashExecutable) {
    Add-AuditError "interpretador Bash utilizável não encontrado"
}
else {

    Push-Location -LiteralPath $repoRoot
    try {
        foreach ($relative in $shellScripts) {
            & $bashExecutable -n -- $relative *> $null

            if ($LASTEXITCODE -ne 0) {
                Add-AuditError "sintaxe Bash inválida em $relative"
            }
        }
    }
    finally {
        Pop-Location
    }
}

Write-AuditOk "políticas e sintaxe dos scripts analisadas"

$auditPath = Join-Path $repoRoot "tools/audit_publication.ps1"
$parseTokens = $null
$parseErrors = $null

[void][System.Management.Automation.Language.Parser]::ParseFile(
    $auditPath,
    [ref]$parseTokens,
    [ref]$parseErrors
)

if (@($parseErrors).Count -ne 0) {
    Add-AuditError "sintaxe PowerShell inválida na ferramenta de auditoria"
}
else {
    Write-AuditOk "sintaxe PowerShell validada"
}

foreach ($relative in $expectedFiles) {
    if (-not $fileMap.ContainsKey($relative)) {
        continue
    }

    git -C $repoRoot check-ignore --quiet --no-index -- $relative 2>$null
    $ignoreResult = $LASTEXITCODE

    if ($ignoreResult -eq 0) {
        Add-AuditError "arquivo permitido está coberto pelo .gitignore: $relative"
    }
    elseif ($ignoreResult -ne 1) {
        Add-AuditError "não foi possível avaliar o .gitignore para $relative"
    }
}

foreach ($relative in $shellScripts) {
    $stageEntry = @(
        git -C $repoRoot ls-files --stage -- $relative
    )

    if ($LASTEXITCODE -ne 0) {
        Add-AuditError "não foi possível consultar o modo Git de $relative"
        continue
    }

    if (
        $stageEntry.Count -gt 0 -and
        $stageEntry[0] -notmatch '^100755 '
    ) {
        Add-AuditError "script versionado sem modo executável: $relative"
    }
}

Write-AuditOk ".gitignore e modos Git analisados"

if ($script:AuditErrors.Count -ne 0) {
    Write-Host (
        "[audit] publicação bloqueada: {0} problema(s)" -f
        $script:AuditErrors.Count
    )

    throw "auditoria pública não aprovada"
}

Write-Host (
    "[ok] auditoria pública integral aprovada: {0} arquivos" -f
    $expectedFiles.Count
)
