function [value] = Func_ExtractPointValue_rrs(row,col,A)
%   站点(long,lat)在影像上3*3窗口均值（已知该站点在影像A上的行列号row col求在Adata中3*3窗口的值value）
% MYD04无效值unvalid=-9999；idw插值无效值unvalid=0
%   QA为影像A的质量标记 2 good ； 3  very good
%存3*3窗口内maen  tag std  cv validnum
%实际验证仅选tag=3或tag=1的值
%要不要当前值tag=4是当前点值；
%tag=3是当前点有值且3*3窗口至少5个点的均值；
%tag=2是当前点无值且3*3窗口至少5个点的均值；
%tag=1是当前点有值但3*3窗口1-4个点的均值
%tag=0是当前点无值且3*3窗口1-4个点的均值；
%CV=std/mean
%A(find(QA<2))=unvalid;%质量控制（IDW插值都做了质量控制所以其QA数据集QA都赋值为3了；这里主要对MYD04进行筛选）

rowmax=size(A,1);
colmax=size(A,2);
if (row>=1)&&(row<=rowmax)&&(col>=1)&&(col<=colmax)
    %3*3窗口上下标
    row_1=max(1,row-1);
    row_2=min(row+1,rowmax);
    col_1=max(1,col-1);
    col_2=min(col+1,colmax);
    A_win=A(row_1:row_2,col_1:col_2);
    %     indAOD=find(A_win>0);
    indAOD=find(A_win>0);
%     indAOD=find(A_win~=unvalid);%aod为负数是存在的 https://zhidao.baidu.com/question/750113766224596932.html
    AOD_num=size(indAOD,1);%总个数
    if ~isempty(indAOD)%1、3*3windows至少1个有效数据
        if A(row,col)>0  
            if AOD_num>=5
                tag=3;%1、该点有值，窗口内有至少5个有效数据，标记为3
            else
                tag=1;%该点有值，窗口内有少于5个有效数据，标记为1
            end
        else%该点无值
            if AOD_num>=5
                tag=2;%2、该点无值，窗口内有至少5个有效数据，标记为2
            else
                tag=0;%3、该点无值，窗口内有少于5个有效数据，标记为0
            end
        end
        a_windows=double(A_win(indAOD));
        AOD_mean=mean(a_windows(:));
        %AOD_max=max(a_windows(:));
        %AOD_min=min(a_windows(:));
        AOD_std=std(a_windows(:));
        cv=AOD_std/AOD_mean;
        value=[AOD_mean,tag,AOD_std,cv,AOD_num];
    else%3*3窗口无有效数据
        value=[NaN,NaN,NaN,NaN,0];
    end
else%不在范围内
    value=[NaN,NaN,NaN,NaN,0];
end
end