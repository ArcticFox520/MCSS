#!/bin/env bash
cd $HOME
export red="\033[31m"
export green="\033[32m"
export yellow="\033[33m"
export blue="\033[34m"
export purple="\033[35m"
export cyan="\033[36m"
export white="\033[37m"
export background="\033[0m"

if [ $(command -v apt) ];then
    pkg_install="apt install -y"
elif [ $(command -v yum) ];then
    pkg_install="yum install -y"
elif [ $(command -v dnf) ];then
    pkg_install="dnf install -y"
elif [ $(command -v pacman) ];then
    pkg_install="pacman -S --noconfirm --needed"
elif [ $(command -v pkg) ];then
    pkg_install="pkg install -y"
fi

function pkg_install(){
i=0
echo -e ${yellow}安装软件 ${pkg}${background}
until ${pkg_install} ${pkg}
do
    if [ ${i} -eq 3 ]
        then
            echo -e ${red}错误次数过多 退出${background}
            exit
    fi
    i=$((${i}+1))
    echo -en ${red}命令执行失败 ${green}3秒后重试${background}
    sleep 3s
    echo
done
}

pkg_list=("tar" \
"gzip" \
"pv" \
"wget" \
"curl" \
"unzip" \
"git" \
"tmux" \
"jq"
"ncat")

for package in ${pkg_list[@]}
do
    if [ -x "$(command -v pacman)" ];then
        if ! pacman -Qi "${package}" > /dev/null 2>&1;then
            pkg="${package} ${pkg}" 
        fi
    elif [ -x "$(command -v apt)" ];then
        if ! dpkg -s "${package}" > /dev/null 2>&1;then
            pkg="${package} ${pkg}"
        fi
    elif [ -x "$(command -v yum)" ];then
        if ! yum list installed "${package}" > /dev/null 2>&1;then
            pkg="${package} ${pkg}"
        fi
    elif [ -x "$(command -v dnf)" ];then
        if ! dnf list installed "${package}" > /dev/null 2>&1;then
            pkg="${package} ${pkg}"
        fi
    elif [ -x "$(command -v pkg)" ];then
        if ! dpkg -s "${package}" > /dev/null 2>&1;then
            pkg="${package} ${pkg}"
        fi
    fi
done

if [ ! -z "${pkg}" ];then
    if [ -x "$(command -v pacman)" ];then
        pacman -Syy
        pkg_install
    elif [ -x "$(command -v apt)" ];then
        apt update -y
        pkg_install
    elif [ -x "$(command -v yum)" ];then
        yum makecache -y
        pkg_install
    elif [ -x "$(command -v dnf)" ];then
        dnf makecache -y
        pkg_install
    elif [ -x "$(command -v pkg)" ];then
        pkg update -y
        pkg_install
    fi
fi

if [ -x "$(command -v whiptail)" ];then
    dialog_whiptail=whiptail
elif [ -x "$(command -v dialog)" ];then
    dialog_whiptail=dialog
else
    pkg=dialog
    pkg_install
fi