function [value] = Func_ExtractPointValue_rrs(row,col,A)
%   վ��(long,lat)��Ӱ����3*3���ھ�ֵ����֪��վ����Ӱ��A�ϵ����к�row col����Adata��3*3���ڵ�ֵvalue��
% MYD04��Чֵunvalid=-9999��idw��ֵ��Чֵunvalid=0
%   QAΪӰ��A��������� 2 good �� 3  very good
%��3*3������maen  tag std  cv validnum
%ʵ����֤��ѡtag=3��tag=1��ֵ
%Ҫ��Ҫ��ǰֵtag=4�ǵ�ǰ��ֵ��
%tag=3�ǵ�ǰ����ֵ��3*3��������5����ľ�ֵ��
%tag=2�ǵ�ǰ����ֵ��3*3��������5����ľ�ֵ��
%tag=1�ǵ�ǰ����ֵ��3*3����1-4����ľ�ֵ
%tag=0�ǵ�ǰ����ֵ��3*3����1-4����ľ�ֵ��
%CV=std/mean
%A(find(QA<2))=unvalid;%�������ƣ�IDW��ֵ��������������������QA���ݼ�QA����ֵΪ3�ˣ�������Ҫ��MYD04����ɸѡ��

rowmax=size(A,1);
colmax=size(A,2);
if (row>=1)&&(row<=rowmax)&&(col>=1)&&(col<=colmax)
    %3*3�������±�
    row_1=max(1,row-1);
    row_2=min(row+1,rowmax);
    col_1=max(1,col-1);
    col_2=min(col+1,colmax);
    A_win=A(row_1:row_2,col_1:col_2);
    %     indAOD=find(A_win>0);
    indAOD=find(A_win>0);
%     indAOD=find(A_win~=unvalid);%aodΪ�����Ǵ��ڵ� https://zhidao.baidu.com/question/750113766224596932.html
    AOD_num=size(indAOD,1);%�ܸ���
    if ~isempty(indAOD)%1��3*3windows����1����Ч����
        if A(row,col)>0  
            if AOD_num>=5
                tag=3;%1���õ���ֵ��������������5����Ч���ݣ����Ϊ3
            else
                tag=1;%�õ���ֵ��������������5����Ч���ݣ����Ϊ1
            end
        else%�õ���ֵ
            if AOD_num>=5
                tag=2;%2���õ���ֵ��������������5����Ч���ݣ����Ϊ2
            else
                tag=0;%3���õ���ֵ��������������5����Ч���ݣ����Ϊ0
            end
        end
        a_windows=double(A_win(indAOD));
        AOD_mean=mean(a_windows(:));
        %AOD_max=max(a_windows(:));
        %AOD_min=min(a_windows(:));
        AOD_std=std(a_windows(:));
        cv=AOD_std/AOD_mean;
        value=[AOD_mean,tag,AOD_std,cv,AOD_num];
    else%3*3��������Ч����
        value=[NaN,NaN,NaN,NaN,0];
    end
else%���ڷ�Χ��
    value=[NaN,NaN,NaN,NaN,0];
end
end