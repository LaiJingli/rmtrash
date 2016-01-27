rmtrash 是linux和mac下命令行版本rm的回收站，安装后对用户透明，符合正常使用rm的习惯(支持rm -fr file哦)，有了他再也不怕rm时候手颤抖了。  
rmtrash stands for "rm trash" which acts just like the system built-in rm command,and just moves the file to the trash for recovery when needed.


1、使用说明  
（1）安装  
wget --no-check-certificate https://raw.githubusercontent.com/LaiJingli/rmtrash/master/rmtrash.sh  
mv rmtrash.sh /bin/  
chmod +x /bin/rmtrash.sh  

a、如果仅对单个用户启用回收站，只需第一次执行如下命令即可：  
/bin/rmtrash.sh  

b、如果想对全局所有用户启用回收站，需要修改bashrc全局配置文件后即可：  
echo "alias rm=/bin/rmtrash.sh" >>/etc/bashrc  

（2）使用  
rm -h  
Usage1: rmtrash.sh file1 [file2] [dir3] [....] delete the files or dirs,and mv them to the rmtrash recycle bin
Usage2: rm         file1 [file2] [dir3] [....] delete the files or dirs,and mv them to the rmtrash recycle bin
        rm is alias to rmtrash.sh.
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

如果有问题，执行以下2条命令排查,或者退出重新登录系统    
source ~/.bashrc  
alias |grep rm  

（3）如果需要彻底删除文件  
a、# rm -e 清空回收站  
b、# /bin/rm file 直接删除文件而不经过回收站  

2、适用系统linux、mac osx

