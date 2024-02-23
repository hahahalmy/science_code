import pandas as pd
import xarray as xr
import os
import numpy as np
import sys

# 根据提供的longitude 和latitude
def func_lonlat2rowcol_2_1hang2(long, lat, lon_array, lat_array, n_row, n_col):
    # Alonglat行存储读取的HDF的lon, lat数据集 n_row行列数size
    # 方法3：经度和纬度差绝对值的和最小，且对于边界点设置阈值剔除在外面的点---星下点（中心像元？）大小最小为10km即0.1°，一半为0.05
    Along = lon_array.values.flatten()
    Alat = lat_array.values.flatten()
    idx_lon = np.where(Along != -999)
    idx_lat = np.where(Alat != -999)

    Along_new = Along[idx_lon]
    Alat_new = Alat[idx_lat]

    if (np.round(np.max(Along_new)) == 180 and np.round(np.min(Along_new)) == -180) or \
            (np.round(np.max(Alat_new)) == 90 and np.round(np.min(Alat_new)) == -90):
        tag = 0
    else:
        if (long <= np.max(Along_new)) and (long >= np.min(Along_new)) and \
                (lat <= np.max(Alat_new)) and (lat >= np.min(Alat_new)):
            diff = np.sqrt(np.power((long - Along_new), 2) + np.power((lat - Alat_new), 2))  # 改为平方和
            mindiff = np.min(diff) # 找出最小距离

            idx_lonlatnew = np.where(diff == mindiff)[0]
            minlon = Along_new[idx_lonlatnew[0]]
            minlat = Alat_new[idx_lonlatnew[0]]
            idx_min = np.intersect1d(np.where(Along == minlon), np.where(Alat == minlat))
            Along_arr = np.reshape(Along, (n_row, n_col))
            row1, col1 = np.where(Along_arr == Along[idx_min])
            Alat_arr = np.reshape(Alat, (n_row, n_col))
            row2, col2 = np.where(Alat_arr == Alat[idx_min])

            arr1_tuples = [tuple(row) for row in np.column_stack((row1, col1))]
            arr2_tuples = [tuple(row) for row in np.column_stack((row2, col2))]

            # 找到两个大数组中相同的小数组
            intersection = set(arr1_tuples).intersection(arr2_tuples)

            # 将交集转换回数组形式
            intersection_array = np.array(list(intersection))

            row = intersection_array[0, 0]
            col = intersection_array[0, 1]
            if intersection_array.shape[0] != 1:
                print('找到多个点最小距离')
            tag = 1
            # 边缘像素
            if (row == 0) or (row == n_row - 1) or (col == 0) or (col == n_col - 1):
                tag = 0
        else:
            tag = 0

    if tag == 0:
        row = 0
        col = 0
        mindiff = 9999

    return row, col, mindiff


df = pd.read_csv(r"E:\pCO2\Indian\result\unique_SST_file_new.csv")
l2a_filelist = list(df['l2a_filename'])
l2a_filelist_unique = list(set(l2a_filelist))
path_server = 'Z:/172_18_31_54/'

# 创建一个空的 DataFrame
df_result = pd.DataFrame(columns=[
    'point_id', 'Longitude', 'Latitude',
    'Rrs_412', 'Rrs_443', 'Rrs_469', 'Rrs_488', 'Rrs_531',
    'Rrs_547', 'Rrs_555', 'Rrs_645', 'Rrs_667', 'Rrs_678',
    'Chlor_a', 'L2_Flags', 'Matched_Longitude', 'Matched_Latitude'
])

# 定义输出文件路径
error_file = 'error.log'

geophysical_path = 'geophysical_data'
location_path = 'navigation_data'
# 逐个打开匹配到的l2a文件
for filename in l2a_filelist_unique:
    print(filename)
    year_str = filename[11:15]
    if year_str in ['2009', '2011', '2012', '2013', '2014', '2015', '2016', '2017']:
        path_satellite = f"{path_server}/data1/global_aqua_l2_nasa/{year_str}/{filename}"
    elif year_str in ['2003', '2004', '2005', '2006', '2007', '2008']:
        path_satellite = f"{path_server}/data3/global_aqua_l2_nasa/{year_str}/{filename}"
    else:
        path_satellite = f"{path_server}/data6/global_aqua_l2_nasa/{year_str}/{filename}"

    if os.path.exists(path_satellite):
        # 找出所有与该文件名相同的行
        matching_rows = df[df["l2a_filename"] == filename]
        print("该l2a文件匹配到的点位共有： ", matching_rows.shape[0])
        # 判断该文件能否正常打开
        try:
            # 尝试打开文件
            xr.open_dataset(path_satellite)
        except Exception as e:
            # 打开文件，将标准输出流追加到文件
            with open(error_file, 'a+') as f:
                # 将标准输出流重定向到文件
                sys.stdout = f
                # 执行输出操作
                print(f"文件{filename}无法打开：{e}")
            # 恢复标准输出流
            sys.stdout = sys.__stdout__  # 恢复标准输出流到默认值
            continue

        # 打开所需要提取的数据集
        geophysical_data = xr.open_dataset(path_satellite, group = geophysical_path)
        Rrs_412 = geophysical_data['Rrs_412']
        Rrs_443 = geophysical_data['Rrs_443']
        Rrs_469 = geophysical_data['Rrs_469']
        Rrs_488 = geophysical_data['Rrs_488']
        Rrs_531 = geophysical_data['Rrs_531']
        Rrs_547 = geophysical_data['Rrs_547']
        Rrs_555 = geophysical_data['Rrs_555']
        Rrs_645 = geophysical_data['Rrs_645']
        Rrs_667 = geophysical_data['Rrs_667']
        Rrs_678 = geophysical_data['Rrs_678']
        chlor_a = geophysical_data['chlor_a']
        l2_flags = geophysical_data['l2_flags']
        print("Rrs's shape = ", Rrs_678.shape)
        # 打开位置信息
        location_data = xr.open_dataset(path_satellite, group = location_path)
        lon_array = location_data['longitude']
        lat_array = location_data['latitude']
        print("Longitude's shape = ", lon_array.shape)
        n_row = lon_array.shape[0]
        n_col = lon_array.shape[1]

        # 开始对每个点位进行Rrs提取
        for index, row in matching_rows.iterrows():
            # 获取当前行的特定列信息
            longitude = row['lon']
            latitude = row['lat']
            point_id = row['point_id']
            match_row, match_col, match_diff = func_lonlat2rowcol_2_1hang2(longitude, latitude, lon_array, lat_array, n_row, n_col)
            rrs412 = Rrs_412.values[match_row, match_col]
            rrs443 = Rrs_443.values[match_row, match_col]
            rrs469 = Rrs_469.values[match_row, match_col]
            rrs488 = Rrs_488.values[match_row, match_col]
            rrs531 = Rrs_531.values[match_row, match_col]
            rrs547 = Rrs_547.values[match_row, match_col]
            rrs555 = Rrs_555.values[match_row, match_col]
            rrs645 = Rrs_645.values[match_row, match_col]
            rrs667 = Rrs_667.values[match_row, match_col]
            rrs678 = Rrs_678.values[match_row, match_col]
            chla = chlor_a.values[match_row, match_col]
            l2_flag = l2_flags.values[match_row, match_col]
            match_lon = lon_array.values[match_row, match_col]
            match_lat = lat_array.values[match_row, match_col]

            # # 在这里进行针对当前行的操作，例如打印经纬度信息
            # print(f"经度：{longitude}, 纬度：{latitude}")
            # print(f"匹配点位精度{match_lon}, 纬度{match_lat}")

            # 将数据添加到 DataFrame 中
            df_temp = pd.DataFrame({
                'point_id': [point_id],
                'Longitude': [longitude],
                'Latitude': [latitude],
                'Matched_Longitude': [match_lon],
                'Matched_Latitude': [match_lat],
                'Rrs_412': [rrs412],
                'Rrs_443': [rrs443],
                'Rrs_469': [rrs469],
                'Rrs_488': [rrs488],
                'Rrs_531': [rrs531],
                'Rrs_547': [rrs547],
                'Rrs_555': [rrs555],
                'Rrs_645': [rrs645],
                'Rrs_667': [rrs667],
                'Rrs_678': [rrs678],
                'Chlor_a': [chla],
                'L2_Flags': [l2_flag]
            })

            df_result = pd.concat([df_result, df_temp], ignore_index=True)
        # print("open this file successful\n")
    else:
        print(f"don't have this file{filename}\n")

# 将 DataFrame 保存为 CSV 文件
df_result.to_csv('output.csv', index=False)

