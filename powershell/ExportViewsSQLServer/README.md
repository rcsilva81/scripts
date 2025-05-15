# ExportViews

Script PowerShell para exportar dados de views do SQL Server para arquivos CSV, utilizando variáveis de ambiente para maior segurança e log de execução.

## Pré-requisitos

- PowerShell
- Módulo SqlServer (instale com: `Install-Module -Name SqlServer`)
- Permissão para criar arquivos em `d:\exportgs\` (ou altere o caminho no script)

## Configuração das Variáveis de Ambiente

Antes de executar o script, defina as variáveis de ambiente para as credenciais do banco de dados.

### Windows 10/11 (Prompt de Comando ou PowerShell)

No PowerShell, execute:
```powershell
$env:DB_SQLSERVER = "NOME_DO_SERVIDOR\\INSTANCIA"
$env:DB_DATABASE = "NOME_DO_BANCO"
$env:DB_USER = "USUARIO"
$env:DB_PASS = "SENHA"
```
Essas variáveis só valem para a sessão atual. Para torná-las permanentes:
```powershell
[System.Environment]::SetEnvironmentVariable('DB_SQLSERVER', 'NOME_DO_SERVIDOR\\INSTANCIA', 'User')
[System.Environment]::SetEnvironmentVariable('DB_DATABASE', 'NOME_DO_BANCO', 'User')
[System.Environment]::SetEnvironmentVariable('DB_USER', 'USUARIO', 'User')
[System.Environment]::SetEnvironmentVariable('DB_PASS', 'SENHA', 'User')
```
Depois, reinicie o PowerShell.

### Windows Server (Prompt de Comando ou PowerShell)
O procedimento é o mesmo. Se for rodar via Agendador de Tarefas, defina as variáveis de ambiente do usuário que executará a tarefa, ou configure-as no próprio script antes da execução (não recomendado para produção).

## Execução do Script

No PowerShell:
```powershell
cd "Caminho/para/o/script"
./ExportViews.ps1
```

## Logs

O script gera um arquivo de log em `d:\exportgs\ExportViews.log` com todas as execuções e eventuais erros.

## Personalização

- Altere os nomes das views e arquivos no script conforme sua necessidade.
- Não armazene credenciais no script nem em repositórios públicos.

---

Dúvidas? Abra uma issue no repositório! 