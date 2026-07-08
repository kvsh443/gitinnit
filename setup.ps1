$ErrorActionPreference = "Stop"
if (!(Get-Command winget -ErrorAction SilentlyContinue)) { throw "Winget missing" }
$needGit = !(Get-Command git -ErrorAction SilentlyContinue)
$needGh = !(Get-Command gh -ErrorAction SilentlyContinue)
if ($needGit) { winget install --id Git.Git --silent --accept-source-agreements --accept-package-agreements }
if ($needGh) { winget install --id GitHub.cli --silent --accept-source-agreements --accept-package-agreements }
if ($needGit -or $needGh) {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path += ";C:\Program Files\Git\cmd\;C:\Program Files\GitHub CLI\"
    if (!(Get-Command git -ErrorAction SilentlyContinue)) { throw "Git missing after install" }
    if (!(Get-Command gh -ErrorAction SilentlyContinue)) { throw "GH CLI missing after install" }
}
$env:BROWSER = "none"
echo "Y" | gh auth login --hostname github.com --git-protocol https --web --scopes user
$u = gh api user --jq '.login'
$e = ((gh api user/emails --jq ".[].email") | Select-String "noreply").ToString().Trim()
if ([string]::IsNullOrEmpty($u) -or [string]::IsNullOrEmpty($e)) { throw "Failed to fetch profile" }
Write-Output "Variables fetched:"
Write-Output "`$u = $u"
Write-Output "`$e = $e"
git config --global user.name "$u"
git config --global user.email "$e"
git config --global user.name
git config --global user.email