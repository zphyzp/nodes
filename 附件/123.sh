my_dir=/data/soft
if [ ! -d "$my_dir" ]; then
        mkdir $my_dir
else
        echo "文件夹已存在"
fi
}