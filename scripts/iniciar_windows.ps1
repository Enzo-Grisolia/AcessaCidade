# Execute este script NA RAIZ da pasta do protótipo, no PowerShell.
$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error 'Flutter não encontrado no PATH. Configure o SDK antes de continuar.'
    exit 1
}
flutter create --project-name acessacidade --platforms=android,web .
if ($LASTEXITCODE -ne 0) { throw 'Falha ao gerar plataformas Flutter' }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Falha ao instalar dependências' }
Write-Host "Projeto preparado. Execute: flutter run -d chrome"
Write-Host "No Android, adicione permissao INTERNET em android/app/src/main/AndroidManifest.xml caso ausente."
