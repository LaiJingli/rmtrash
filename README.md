rmtrash 是linux和mac下命令行版本rm的回收站，安装后对用户透明，符合正常使用rm的习惯，有了他再也不怕rm时候手颤抖了。
rmtrash stands for "rm trash" which acts just like the system built-in rm command,and just moves the file to the trash for recovery when needed.


1、使用说明
（1）安装
wget --no-check-certificate https://raw.githubusercontent.com/LaiJingli/rmtrash/master/rmtrash.sh
mv rmtrash.sh /bin/
chmod +x /bin/rmtrash.sh
/bin/rmtrash.sh

（2）使用
rm -h

如果有问题，执行以下2条命令排查即可
source ~/.bashrc
alias |grep rm

（3）如果需要彻底删除文件
a、# rm -e 清空回收站
b、# /bin/rm file 直接删除文件而不经过回收站

2、适用系统linux、mac osx

