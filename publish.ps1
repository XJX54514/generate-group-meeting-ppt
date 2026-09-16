# 一键发布本技能到 GitHub
#
# 用法（在本目录下打开 PowerShell）：
#   .\publish.ps1                       # 会提示输入 GitHub 用户名
#   .\publish.ps1 -Owner yourname -Repo generate-group-meeting-ppt
#
# 推送时 git 会提示输入用户名与密码：密码处粘贴 Personal Access Token（不是账号密码）。
# Token 需要 repo 权限；细粒度 token 勾选 "Contents: Read and write"。

param(
    [string]$Owner = "",
    [string]$Repo = "generate-group-meeting-ppt"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path ".git")) {
    Write-Host "[ERROR] 当前目录不是 git 仓库，请先 cd 到技能目录。" -ForegroundColor Red
    exit 1
}

if (-not $Owner) {
    $Owner = Read-Host "请输入 GitHub 用户名"
}

$url = "https://github.com/$Owner/$Repo.git"
Write-Host "[INFO] 目标仓库: $url" -ForegroundColor Cyan

# 让 git 在当前环境使用 openssl TLS 后端（部分环境 schannel 不可用）
git config http.sslBackend openssl

$existing = git remote 2>$null
if ($existing -contains "origin") {
    git remote set-url origin $url
} else {
    git remote add origin $url
}

git branch -M main

Write-Host "[INFO] 开始推送（如提示登录，用户名填 $Owner，密码粘贴 PAT）..." -ForegroundColor Cyan
git push -u origin main

Write-Host "[OK] 推送完成：$url" -ForegroundColor Green
