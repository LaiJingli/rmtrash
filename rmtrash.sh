#!/bin/bash
###rmtrash,rm command line recycle bin for linux and mac osx.
### laijingli2006@gmail.com

###trash目录define
realrm="/bin/rm"
trash_dir=~/.rmtrash/
trash_log=~/.rmtrash.log
###判断trash目录是否存在，不存在则创建
if [ ! -d $trash_dir ] ;then
	mkdir -v $trash_dir
fi

###动态修改用户shell中的alias配置
os_type=`uname`
shell_path=$SHELL
shell_type=`echo $SHELL|awk -F/ '{print $NF}'`
alias_file=~/.${shell_type}rc
alias_rm=`cat $alias_file|grep ^"alias rm="`
return_value=$?
#echo return_value: $return_value
#echo alias_rm: $alias_rm
###如果不存在rm alias，则生成
if [[ $return_value -ne 0 ]] ;then
	echo first time to rum rmtrash
	echo "alias rm=/bin/rmtrash.sh" >>$alias_file && source $alias_file
###如果存在rm alias，且不是指向rmtrash的，则注释掉，区分linux 和mac
elif [[ "$alias_rm" != "alias rm=/bin/rmtrash.sh" ]];then
	echo already has alias rm,and must commit out
	if [[ $os_type == Darwin ]];then
		sed -i .bak 's/^alias\ rm=/#alias\ rm=/g' $alias_file && \
		echo "alias rm=/bin/rmtrash.sh" >>$alias_file && \
		source $alias_file
	elif [[ $os_type == Linux ]];then
		sed -i.bak 's/^alias\ rm=/#alias\ rm=/g' $alias_file && \
		echo "alias rm=/bin/rmtrash.sh" >>$alias_file && \
		source $alias_file
	fi
fi

####function define
###usage function
rm_usage () {
	cat <<EOF
Usage: `basename $0` file1 [file2 file3....] delete the file,and mv them to the rmtrash recycle bin
options:
	-r  restore selected files to the originalpath from rmtrash recycle bin
	-l  list the contens of rmtrash recycle bin
	-i  show detailed log of the deleted file history
	-e  empty the rmtrash recycle bin
	-h  display this help menu
EOF
}


###rm mv function
rm_mv () {
	echo ----------------------------
	now=`date +%Y%m%d_%H:%M:%S`
	###将用户输入的文件循环mv到trash中
	###for file in $file_list ;do
		#echo $file
		###提取用户输入参数的文件名、目录名，拼出绝对路径
		file_name=`basename $file`	
		file_dir=$(cd `dirname $file`;pwd)
		file_fullpath=$file_dir/$file_name
		###判断要删除的文件或者目录大小是否超过2G
		#echo file_fullpath: $file_fullpath
		#if [[ "$file_fullpath" == "/*" ]];then
		#	echo action deny!
		#else
			###mv成功记录log,记录删除时的文件、目录的路径等信息到log，以便恢复数据
			mv $file_fullpath $trash_dir && \
			echo $now deleted by `whoami` from: $file_fullpath >> $trash_log && \
			echo -e "\033[31m\033[05m $file is deleted from $file_fullpath\033[0m" 
			#cat $trash_log
		#fi
	###done
}

###rm list function
rm_list () {
	echo ----------------------------
	echo list trash_dir contents:
	ls $trash_dir
}


###rm restore function
rm_restore () {
	echo ----------------------------
	echo -en "请选择要恢复的文件名(多个文件中间空格分隔,取消ctl+c):"
	read reply
	for file in $reply ;do
		originalpath=`cat $trash_log|awk  '{print $6}'|grep /$file$`
		mv $trash_dir$file  $originalpath && \
		###linux和mac下sed的用法有细微差别，故需通过操作系统类型进行选择对应的sed格式
		if [[ $os_type == Darwin ]];then 
			sed -i .bak "/\/$file$/d" $trash_log
			echo os_type=Darwin
		elif [[ $os_type == Linux ]];then
			sed -i.bak "/\/$file$/d" $trash_log
			echo os_type=Linux
		fi && \
		echo -e  "\033[32m\033[05m$file restore ok to originalpath=$originalpath\033[0m"
	done
}

### rm show delete log function
rm_infolog () {
	echo ----------------------------
	echo detailed deleted file log:
	cat $trash_log
}


###rm empty trash function
rm_empty () {
	echo ----------------------------
	echo empty trash:
	/bin/rm -fr $trash_dir/* && \
	echo >$trash_log && \
	echo -e "\033[31m\033[05m The trash bin has been emptyed\033[0m"
}


###跨分区的问题

#####主程序开始
###参数个数为0，输出help
if [ $# -eq 0 ] ;then rm_usage ;fi
###根据用户输入选项执行相应动作
while getopts lrieh option ;do
case "$option" in
		l) rm_list;;
		r) rm_list
		   rm_restore;;
		i) rm_infolog;;
		h) rm_usage;;
		e) rm_empty;;
		\?)rm_usage
		   exit 1;;
	esac
done
shift $((OPTIND-1))

###将文件名的参数依次传递给rm_mv函数
while [ $# -ne 0 ];do
	file=$1
	echo file=$file 
	rm_mv
	shift
done


