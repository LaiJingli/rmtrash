#!/bin/bash
###rmtrash,rm command line recycle bin
realrm="/bin/rm"
trash_dir=~/.rmtrash/
trash_log=~/.rmtrash.log
file_list=$@

###修改用户shell中的alias
echo "current shell is: "$SHELL
cat /Users/laijingli/.zshrc|grep ^"alias rm"
retrurn=$?
if [[ $return -ne 0 ]] ;then
	echo first time to rum rmtrash

fi

#alias rm=rmtrash


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
	##判断trash目录是否存在，不存在则创建
	now=`date +%Y%m%d_%H:%M:%S`
	if [ ! -d $trash_dir ] ;then 
		mkdir -v $trash_dir
       	fi

	###将用户输入的文件循环mv到trash中
	for file in $file_list ;do
		#echo $file
		###提取用户输入参数的文件名、目录名，拼出绝对路径
		file_name=`basename $file`	
		file_dir=$(cd `dirname $file`;pwd)
		file_fullpath=$file_dir/$file_name
		###判断要删除的文件或者目录大小是否超过2G
		###mv成功记录log,记录删除时的文件、目录的路径等信息到log，以便恢复数据
		mv $file_fullpath $trash_dir && \
		echo $now deleted by `whoami` from: $file_fullpath >> $trash_log && \
		echo -e "\033[31m\033[05m $file is deleted from $file_fullpath\033[0m" 
		#cat $trash_log
	done
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
		sed -i .bak "/\/$file$/d" $trash_log && \
		echo -e  "\033[32m\033[05m$file restore ok to originalpath=$originalpath\033[0m"

		#echo ----------------
		#cat $trash_log
		#echo ---------------
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
	/bin/rm -fr $trash_dir/* && echo >$trash_log && echo -e "\033[31m\033[05m The trash bin has been emptyed\033[0m"
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
		\?)rm_usage;;
	esac
done
shift $((OPTIND-1))

while [ $# -ne 0 ];do
	rm_mv
	shift
done


