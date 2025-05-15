#!/bin/bash

# ------------------------------------------------------------------------------
#   Faz o downalod do arquivo de backup no formato .gz, extrai e restaura para o
# schema definido pelo usuário (TST no exemplo abaixo).
# Ex.: ./restore2.sh source_ANO-MES-DIA_HORA-MIN.gz TST
# *** Alterar a variável table_name para o nome da tabela que precisa ser restaurada
#
# Data          Desenvolvedor           Notas
# 08-AGO-2023	ROBERT SILVA 	       Criado para fazer o restore se carregar os dados de tabelas específicas.
# ------------------------------------------------------------------------------
set -x

echo "Verificando se 2 os parâmetros foram preenchidos..."
if [ $# -lt 2 ]
then
	echo "Digite o nome do arquivo zipado e o schema para recuperar."
	echo "Ex.: ./restore.sh source_ANO-MES-DIA_HORA-MIN TST"
	exit
fi

clear

echo "Preparando variáveis source e target..."
source=$1
source_3="${source:0:3}"

source_upper="${source_3^^}"
source_lower="${source_3,,}"

source_routines=$source"_routines.gz"
source_tables=$source"_tables.gz"

target=$2
target="${target^^}"

target_routines=$target"_routines"
target_tables=$target"_tables"

table_name="tbl_medicao"

#backup_dir="/root/backups/root/"
backup_dir="/var/lib/mysql/backups/"
#backup_dir2="/root/backups/root/root"
backup_dir2="/var/lib/mysql/backups/root"
if [ ! -d "$backup_dir" ]; then
	mkdir $backup_dir
fi

logs_dir="/root/logs/"
if [ ! -d "$logs_dir" ]; then
	mkdir $logs_dir
fi

scripts_dir="/root/scripts/"
if [ ! -d "$scripts_dir" ]; then
	mkdir $scripts_dir
fi

objects_source=$scripts_dir"objects.sql"
objects_target=$backup_dir$target"_objects.sql"

log_file=$logs_dir"restore.log"

echo "Verificando counteúdo da variável $target..."
if [ $target = "PRD" ]
then
	echo "O nome do arquivo de restauração não pode ser PRD."
	echo -ne "\007"
	exit
fi

cd $backup_dir

echo "Baixando e extraindo backup de $source ..."
s3cmd get s3://ggo-db-backup/$source_routines $backup_dir --force
#pigz -d $backup_dir$source_routines
tar -xvzf $backup_dir$source_routines
rm $backup_dir$source_routines -v

s3cmd get s3://ggo-db-backup/$source_tables $backup_dir --force
#pigz -d $backup_dir$source_tables
tar -xvzf $backup_dir$source_tables
rm $backup_dir$source_tables -v

echo "Excluindo schema $target anterior..."
mysql -e "DROP SCHEMA IF EXISTS $target;"

sql_source_routines=$(echo $backup_dir2/temp/$source_routines | sed -e "s/.gz//g")".sql"
sql_target_routines=$backup_dir2/temp/$target_routines".sql"
echo "Criando arquivo $target_routines.sql à partir do $source_routines para importação..."
sed "s/$source_upper/$target/g" $sql_source_routines > $sql_target_routines
rm $sql_source_routines -v

echo "Restaurando novo arquivo $target_routines.sql..."
mysql -u root < $sql_target_routines
rm $sql_target_routines -v

sql_source_tables=$(echo $backup_dir2/temp/$source_tables | sed -e "s/.gz//g")".sql"
sql_rmzero_tables=$backup_dir2/temp/"rm_zeros_tables.sql"
sql_target_tables_1=$backup_dir2/temp/$target_tables"_1.sql"
sql_target_tables=$backup_dir2/temp/$target_tables".sql"

echo "Criando arquivo apenas com a tabela necessaria..."
echo "USE $target;" > $sql_target_tables_1
echo "USE $target;" > $sql_target_tables_1
awk -v table_name=$table_name '
  /CREATE TABLE `'"$table_name"'`/,/;/ {print}
  /INSERT INTO `'"$table_name"'`/,/;/ {print}
' $sql_source_tables >> $sql_target_tables_1

#sed -n "/CREATE TABLE \`$table_name\`/,/;/p;/INSERT INTO \`$table_name\`/,/;/p" $sql_source_tables >> $sql_target_tables_1
rm $sql_source_tables -v

echo "Criando arquivo $target_tables.sql à partir do $source_tables para importação..."
sed "s/'0000-00-00 00:00:00'/NULL/g" $sql_target_tables_1 > $sql_rmzero_tables
rm $sql_target_tables_1 -v

sed "s/$source_upper/$target/g" $sql_rmzero_tables > $sql_target_tables
rm $sql_rmzero_tables -v

#sed -n '/CREATE TABLE `tbl_medicao`/p' $sql_target_tables_1> $sql_target_tables
#sed -n '/INSERT INTO `tbl_medicao`/p' $sql_target_tables_1>> $sql_target_tables
#rm $sql_target_tables_1 -v


# sed "s/$source_upper/$target/g" $sql_source_tables > $sql_target_tables
# rm $sql_source_tables

echo "Restaurando novo arquivo $target_tables.sql..."
mysql --init-command="SET SESSION FOREIGN_KEY_CHECKS=0;" -u root < $sql_target_tables
#rm $sql_target_tables -v

echo "Preparando script de objetos $target_objects.sql..."
sed "s/$source_upper/$target/g" $objects_source > $objects_target

echo "Executando arquivo de comparação $target_objects.sql..."
echo "-------------------------------------------------------------------------------" >> $log_file
echo $(date "+%Y-%m-%d %H:%M:%S") >> $log_file
echo "source = "$source_upper >> $log_file
echo "target = "$target >> $log_file
mysql -u root < $objects_target >> $log_file
echo "-------------------------------------------------------------------------------" >> $log_file
echo $log_file
rm $objects_target -v

echo "Finalizado!!!"