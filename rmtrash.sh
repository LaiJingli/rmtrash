#!/bin/bash
### rmtrash,rm command line recycle bin for linux and mac osx.
### rmtrash 是linux和mac下命令行版本rm的回收站，安装后对用户透明，符合正常使用rm的习惯(支持rm -fr file哦)，有了他再也不怕rm时候手颤抖了。
### rmtrash stands for "rm trash" which acts just like the system built-in rm command,and just moves the file to the trash for recovery when needed.
### https://github.com/LaiJingli/rmtrash
### laijingli2006@gmail.com
### 2015-3-9

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
	echo first time to run rmtrash
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
Usage1: `basename $0` file1 [file2] [dir3] [....] delete the files or dirs,and mv them to the rmtrash recycle bin
Usage2: rm         file1 [file2] [dir3] [....] delete the files or dirs,and mv them to the rmtrash recycle bin
        rm is alias to `basename $0`.
options:
	-f  mv one or more files to the rmtrash recycle bin
	-r  mv one or more files to the rmtrash recycle bin
	-fr mv one or more files to the rmtrash recycle bin
	-rf mv one or more files to the rmtrash recycle bin
	-R  Restore selected files to the originalpath from rmtrash recycle bin
	-l  list the contens of rmtrash recycle bin
	-i  show detailed log of the deleted file history
	-d  delete one or more files by user's input file name from the trash
	-e  empty the rmtrash recycle bin
	-h  display this help menu
EOF
}


###rm mv function
rm_mv () {
	echo ----------------------------
	now=`date +%Y%m%d_%H:%M:%S`
	dupfix=.`date +%Y%m%d%H%M%S`
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
		####判断即将删除的文件在trash目录里是否已存在
		if [[ `ls $trash_dir|grep ^${file_name}$` ]];then	
			##已存在，文件名重复，需要rename，想原始名的基础上加后缀
			trash_dest_path=$trash_dir$file_name$dupfix
			echo trash目录里已存在$file_name,需要rename $file_name$dupfix
		else
			##不重名，直接按原始文件名保存
			trash_dest_path=$trash_dir$file_name
		fi

		####判断如果是要删除文件是根目录，则直接提示并拒绝
		if [[ "$file_name" == "/" ]];then
			echo rm拒绝执行删除根目录操作，否则系统就挂了，你就悲剧了，请检查...
		else
			###mv成功记录log,记录删除时的文件、目录的路径等信息到log，以便恢复数据
			mv $file_fullpath $trash_dest_path && \
			echo $now `date +%s` `whoami` moved from $file_fullpath to $trash_dest_path >> $trash_log && \
			echo -e "\033[31m\033[05m $file is deleted from $file_fullpath\033[0m" 
			#cat $trash_log
		fi

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
		###判断原始位置的是否有同名文件存在
		originalpath=`cat $trash_log|grep /$file$|awk  '{print $5}'`
		if [[ `ls $originalpath` ]];then
			echo -en "originalpath:$originalpath already exists. continue overwrite or not(y/n):"
			read ack
			if   [[ $ack == y ]];then
				echo restore:
			elif [[ $ack == n ]];then
				echo bye && exit
			else
				echo 输入非法 && exit
			fi
		fi
		###
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
	echo -en "empty trash,all backups in trash will be deleted, continue or not(y/n):"
	read ack
	if   [[ $ack == y ]];then
		echo begin to empty trash:
	elif [[ $ack == n ]];then
		echo bye && exit
	else
		echo 输入非法 && exit
	fi
	/bin/rm -fr ${trash_dir}* && \
	echo >$trash_log && \
	echo -e "\033[31m\033[05m The trash bin has been emptyed\033[0m"
}

###rm delete function
rm_delete () {
	echo ----------------------------
	echo -en "请选择trash中要删除的文件名(多个文件中间空格分隔,取消ctl+c):"
	read reply
		for file in $reply ;do
			###if file exist then delete it from trash
			if [[ `ls ${trash_dir}$file` ]];then
				/bin/rm -fr ${trash_dir}$file && \
				###linux和mac下sed的用法有细微差别，故需通过操作系统类型进行选择对应的sed格式
				if [[ $os_type == Darwin ]];then
					sed -i .bak "/\/$file$/d" $trash_log
					echo os_type=Darwin
				elif [[ $os_type == Linux ]];then
					sed -i.bak "/\/$file$/d" $trash_log		
					echo os_type=Linux
				fi && \
					echo -e  "\033[32m\033[05m$file  is deleted from trash ${trash_dir}$file \033[0m"
			else
				echo $file is not exist in $trash_dir
			fi
		done
}

###清空回收站中30天之前执行rm删除过的文件
rm_delete_by_30_days () {
	rm_mv_30_days_ago_timestamp=$1
	###30*24*3600=2592000
	#30_days_by_seconds=2592000
	#cat $trash_log|awk 'BEGIN{30_days_by_seconds=2592000}{if()}'
	awk   'END{
		print 时间差:$2-2592000
		{if ($2-2592000>100) print dayu}
	}
	' $trash_log
}

###跨分区的问题

#####主程序开始
###参数个数为0，输出help
if [ $# -eq 0 ] ;then rm_usage ;fi
###根据用户输入选项执行相应动作
###通过非显示的方式(加入fr选项，但在case里不做匹配操作，遇到含-fr/-rf/-f/-r时直接删除)支持很多用户的使用习惯rm -fr file,rm -rf file
while getopts lRiecdhfr option ;do
case "$option" in
		l) rm_list;;
		R) rm_list
		   rm_restore;;
		i) rm_infolog;;
		h) rm_usage;;
		e) rm_empty;;
		c) rm_delete_by_30_days;;
		d) rm_list
		   rm_delete;;
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


