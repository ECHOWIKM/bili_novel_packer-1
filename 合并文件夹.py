import os
import shutil
import re

def merge_folders(base_path):
    # 获取所有文件夹
    folders = [f for f in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, f))]
    
    # 用于存储带数字前缀和不带数字前缀的文件夹对应关系
    folder_pairs = {}
    
    # 遍历所有文件夹,找出对应关系
    for folder in folders:
        # 检查是否以数字开头
        match = re.match(r'(\d+)(.*)', folder)
        if match:
            # 带数字前缀的文件夹
            number = match.group(1)
            name = match.group(2)
            # 查找对应的不带数字前缀的文件夹
            if name in folders:
                folder_pairs[name] = number + name

    # 合并文件夹
    for name, numbered_name in folder_pairs.items():
        src_path = os.path.join(base_path, name)
        dst_path = os.path.join(base_path, numbered_name)
        
        print(f"合并文件夹: {name} -> {numbered_name}")
        
        # 移动所有文件
        for item in os.listdir(src_path):
            src_item = os.path.join(src_path, item)
            dst_item = os.path.join(dst_path, item)
            
            # 如果目标文件已存在,先删除
            if os.path.exists(dst_item):
                if os.path.isfile(dst_item):
                    os.remove(dst_item)
                else:
                    shutil.rmtree(dst_item)
            
            # 移动文件或文件夹
            shutil.move(src_item, dst_item)
        
        # 删除空的源文件夹
        os.rmdir(src_path)

if __name__ == "__main__":
    # 指定要处理的目录路径
    base_path = r"D:\Github\BBS\bili_novel_packer\build"
    merge_folders(base_path)
    print("合并完成!") 