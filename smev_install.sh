#!/bin/bash

set -x

# Выкачка дистрибутива из Nexus в /tmp


#tmp_dir="$(mktemp -d)"
#distr_path="$tmp_dir/distrib.zip"

tmp_dir="/tmp"                                           # временная папка, куда выкачивается дистрибутив
tmp_distr_path="$tmp_dir/no-docker_3.15.0.tar.gz"        # абсолютный путь к архиву дистрибутива во временной папке
istallation_root_path="/einfahrt"                        # корневая папка, где будут храниться файлы из дистрибутива и логи
installation_path="$istallation_root_path/distr"         # абсолютный путь к папке, в которой будут лежать файлы дистрибутива
logs_path="$istallation_root_path/logs"                  # абсолютный путь к папке, в которой будут лежать логи
path_to_files_in_distr="$tmp_dir/distr/einfahrt"         # абсолютный путь к файлам дистрибутива после распаковки


cd "$tmp_dir" || exit 2

#----------------------------------
mkdir -p $installation_path
mkdir -p $logs_path
touch "$logs_path/output.log"
touch "$logs_path/error.log"
chown -R smevctl:smevctl "$istallation_root_path"
chmod -R ug+rwx "$istallation_root_path"

tar xvzf "$tmp_distr_path" -C "$tmp_dir"
cp -r "$path_to_files_in_distr"/* "$installation_path"


cd "$installation_path"
# Распаковка архива с java
tar xvzf bellsoft*amd64.tar.gz

#java_folder_name=$(basename "$(find . -type d -iname "jdk-*")")
mv jdk-* java # Убрал из названия версию, путь к java используется в eifahrt.service
profile_script_path="/etc/profile.d/smev_env.sh"
echo "export JAVA_HOME=$installation_path/java" > "$profile_script_path"
echo "export PATH=$PATH:$JAVA_HOME/bin" >> "$profile_script_path"


# Установка КриптоПро из состава дистрибутива СМЭВ4
tar xvzf csp-*.tar.gz
csp_folder_name=$(basename "$(find . -type d -iname "csp-*")")
cd "$csp_folder_name"
yum -y install \
        lsb-cprocsp-base*.rpm \
        lsb-cprocsp-rdr-64*.rpm \
        lsb-cprocsp-kc1-64*.rpm \
        lsb-cprocsp-capilite-64*.rpm \
        lsb-cprocsp-devel*.rpm \
        lsb-cprocsp-kc2-64*.rpm \
        cprocsp-curl-64*.rpm

./install.sh

set +x
