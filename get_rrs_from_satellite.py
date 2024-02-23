import pandas as pd
import os
from datetime import datetime, timedelta


def julian_to_mon_day(year,julian):
    # 构建 datetime 对象
    dt = datetime(year=year, month=1, day=1) + timedelta(days=julian - 1)
    # 返回月份和日
    return dt.month, dt.day

def trans_l1a_to_l2a(l1a_name):
    filename = ''
    # 将文件名后缀删除
    name, ext = os.path.splitext(l1a_name)
    if ext == ".bz2":
        filename = name
    else:
        filename = l1a_name
    year_str = filename[1:5]
    julian_str = filename[5:8]
    month, day = julian_to_mon_day(int(year_str), int(julian_str))
    hour_str = filename[8:10]
    min_str = filename[10:12]
    file_prefix = "AQUA_MODIS.{:04d}{:02d}{:02d}T{:02d}{:02d}0".format(int(year_str), month, day, int(hour_str), int(min_str))
    filelist_path = "E:/pCO2/script/" + year_str + "_nasa_filelist.txt"
    filelist = []
    # 打开文件
    with open(filelist_path, 'r') as file:
        # 读取文件内容并按行分割
        filelist = [line.strip() for line in file.readlines()]
    # 从l2a下载文件名中匹配出对应的文件名
    match_result = [s for s in filelist if s.startswith(file_prefix)]
    if match_result:
        return match_result[0]
    else:
        return 'no_l2a_download'



# 读取包含文件名的 CSV 文件
df = pd.read_csv(r"E:\pCO2\Indian\result\unique_SST_file.csv")

# 遍历每一行，将包含逗号的文件名分割成单独的文件名
new_rows = []
for index, row in df.iterrows():
    filenames = row['filelist'].split(',')
    for filename in filenames:
        if filename == "":
            continue
        if filename == "error":
            break
        new_row = row.copy()
        new_row['filelist'] = filename.strip()  # 删除文件名两侧的空格
        new_rows.append(new_row)

# 创建新的 DataFrame，其中每行只有一个文件名
new_df = pd.DataFrame(new_rows)
print(new_df.head())
new_df['l2a_filename'] = new_df['filelist'].apply(trans_l1a_to_l2a)
print(new_df.head(5))

new_df.to_csv(r"E:\pCO2\Indian\result\unique_SST_file_new.csv", index=False)

