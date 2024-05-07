import concurrent.futures
import requests
import re
from datetime import datetime, timedelta
import csv

url = "http://oceancolor.gsfc.nasa.gov/cgi/browse.pl"

prefixUrl = "https://oceancolor.gsfc.nasa.gov"

# calculate day in params
def cal_day(date_str):
    date_format = "%Y-%m-%d"
    date_obj = datetime.strptime(date_str, date_format)
    number = (date_obj - datetime(2002, 7, 4)).days + 11872
    return number

# init params
def init_params(day, north, south, west, east):
    params = {
        'sub': 'level1or2list',
        'per': 'CU',   # CU 查询所有数据   DAY 查询具体某天
        'day': str(day),  # Convert day to string if it's not already
        'prm': 'TC',
        'ndx': '0',
        'sen': 'amod',
        'dnm': 'D',
        'rad': '0',
        'frc': '0',
        'set': '10',
        'n': str(north),
        'w': str(west),
        'e': str(east),
        's': str(south),
    }
    return params

def get_response(params, index_str):
    response = requests.get(url, params=params, verify=False)
    if response.status_code == 200:
        text_content = response.text
        # 利用re正则表达式匹配影像名称
        pattern = re.compile(r'<a\s+href="([^"]*)"><img\s+src="/icons/List.png"')
        match_result = pattern.findall(text_content)
        match_result.append(index_str)
        print(match_result)
        print("query successfully!")
        print(prefixUrl + match_result[0])
        response = requests.get(prefixUrl + match_result[0])
        if response.status_code == 200:
            content = response.text
            lines = content.split('\n')
            return lines
        else:
            print("无法下载文件")
            return ['error', index_str]
    else:
        print("请求失败")
        return ['error', index_str]


def write_results_to_file(results, file_path):
    with open(file_path, 'w') as file:
        for item in results:
            file.write(item + '\n')


if __name__ == '__main__':
    input_file_path = r"E:\pCO2\Coastal\tmp2.csv"
    output_file_path = r"E:\pCO2\Coastal\tmp2.txt"
    results = []
    i = 0
    with open(input_file_path, newline="", encoding='utf-8') as csvfile:
        csv_reader = csv.reader(csvfile)
        next(csv_reader)
        for row in csv_reader:
            print(row)
            lon, lat, yr, mon, day, index = row
            dateStr = yr + '-' + mon + '-' + day
            day_num = cal_day(dateStr)
            if day_num >= 11872:
                param = init_params(day_num, lat, lat, lon, lon)
                result = get_response(param, index)
            else:
                result = ["none"]
            results.append(result)

    flat_list = [item for sublist in results for item in sublist]
    unique_file = list(set(flat_list))
    # print(unique_file)
    # print(len(unique_file))
    write_results_to_file(unique_file, output_file_path)


