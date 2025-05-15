#!/bin/bash
# ------------------------------------------------------------------------------
# Script para exportar os dados de um BD para outro em um novo servidor
#
# Data          Desenvolvedor           Notas
# 26-10-2023    Robert Silva           Criado.
# ------------------------------------------------------------------------------
set -x

vPass="${MYSQL_PASS}"
vUser="${MYSQL_USER}"
vNewHost="${MYSQL_HOST}"
vPort="${MYSQL_PORT}"
vBD2Export="${MYSQL_DATABASE}"
vBD2Be='PRD'
vExportDir='/var/lib/mysql/export/'
vExportRoutinesFile=$vExportDir'export_routines.sql'
vExportTablesFile=$vExportDir'export_tables.sql'
vExportDataFile=$vExportDir'export_data.sql'
vAdminProcsFile='/root/scripts/admin_procs.sql'

# dump somente functions e procs
start_time=$(date +%H:%M:%S)
echo "Dump functions e procs started at: $start_time"

mysqldump --force --no-create-info --no-create-db --routines --no-data --skip-triggers --single-transaction --skip-lock-tables --comments --compact --quick --set-gtid-purged=OFF --log-error=error_routines.log $vBD2Export > $vExportRoutinesFile

end_time=$(date +%H:%M:%S)
echo "Dump functions e procs ended at: $end_time"

# dump somente tables e views
start_time=$(date +%H:%M:%S)
echo "Dump tables e views started at: $start_time"

mysqldump --force --no-create-db --no-data --skip-comments --compact --single-transaction --skip-lock-tables --quick --set-gtid-purged=OFF --log-error=error_tables.log $vBD2Export > $vExportTablesFile

end_time=$(date +%H:%M:%S)
echo "Dump tables e views ended at: $end_time"

# dump somente dados 
# mysqldump --no-create-info --no-create-db --skip-triggers --single-transaction --skip-lock-tables --quick --compact --set-gtid-purged=OFF $vBD2Export > $vExportDataFile

## dump somente dados com ignore table
start_time=$(date +%H:%M:%S)
echo "Dump dados started at: $start_time"

mysqldump --no-create-info --no-create-db --skip-triggers --single-transaction --skip-lock-tables --quick --compact --set-gtid-purged=OFF --ignore-table=PRD.fvs_tbl_log_nao_conformidade --log-error=error_data.log $vBD2Export > $vExportDataFile

end_time=$(date +%H:%M:%S)
echo "Dump dados ended at: $end_time"

# remove definer
start_time=$(date +%H:%M:%S)
echo "Remove definer started at: $start_time"

sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $vExportRoutinesFile
sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $vExportTablesFile

end_time=$(date +%H:%M:%S)
echo "Remove definer ended at: $end_time"


## disable foreign key check
start_time=$(date +%H:%M:%S)
echo "Disable foreign key check started at: $start_time"

sed -i '1i\set foreign_key_checks = 0;' $vExportTablesFile

end_time=$(date +%H:%M:%S)
echo "Disable foreign key check ended at: $end_time"