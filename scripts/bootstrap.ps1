param(
    [string]$PythonCommand = "python",
    [switch]$SkipBrowserInstall
)

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$venvRoot = Join-Path $projectRoot ".venv"
$venvPython = Join-Path $venvRoot "Scripts\python.exe"
$decryptRoot = Join-Path $PSScriptRoot "wechat-decrypt"
$browserRoot = Join-Path $projectRoot ".cache\ms-playwright"
$configTemplate = Join-Path $projectRoot "assets\env.example"
$configPath = Join-Path $projectRoot ".env"

if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    Copy-Item -LiteralPath $configTemplate -Destination $configPath
}
$configTemplate = Join-Path $projectRoot "assets\env.example"
$configPath = Join-Path $projectRoot ".env"

if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    Copy-Item -LiteralPath $configTemplate -Destination $configPath
}

if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
    & $PythonCommand -m venv $venvRoot
    if ($LASTEXITCODE -ne 0) {
        throw "创建 Python 虚拟环境失败。"
    }
}

& $venvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
    throw "升级 pip 失败。"
}

$editableTarget = "{0}[dev]" -f $projectRoot
& $venvPython -m pip install -e $editableTarget
if ($LASTEXITCODE -ne 0) {
    throw "安装 articlemonitor 失败。"
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "找不到 npm，请先安装 Node.js 20 或更高版本。"
}

Push-Location $decryptRoot
try {
    & npm install
    if ($LASTEXITCODE -ne 0) {
        throw "安装视频号解密依赖失败。"
    }
    if (-not $SkipBrowserInstall) {
        New-Item -ItemType Directory -Force -Path $browserRoot | Out-Null
        $env:PLAYWRIGHT_BROWSERS_PATH = $browserRoot
        & npx playwright install chromium
        if ($LASTEXITCODE -ne 0) {
            throw "安装 Playwright Chromium 失败。"
        }
    }
}
finally {
    Pop-Location
}

& $venvPython -c "from article_monitor.project import ensure_project_directories; ensure_project_directories()"
if ($LASTEXITCODE -ne 0) {
    throw "创建项目业务目录失败。"
}

Write-Output "articlemonitor 初始化完成。"
