function [row,col,mindiff] = Func_lonlat2Rowcol_2_1hang2(long,lat,Alonglat,n_row,n_col)
%Alonglat�д洢��ȡ��HDF��lon, lat���ݼ�   n_row������size
%����3�����Ⱥ�γ�Ȳ����ֵ�ĺ���С���Ҷ��ڱ߽��������ֵ�޳�������ĵ�---���µ㣨������Ԫ������С��СΪ10km��0.1�㣬һ��Ϊ0.05
Along=Alonglat(1,:);
Alat=Alonglat(2,:);
idx_lon=find(Along~=-999);
idx_lat=find(Alat~=-999);

Along_new=Along(idx_lon);
Alat_new=Alat(idx_lat);
if ((round(double(max(Along_new(:))))==180)&&(round(double(min(Along_new(:))))==-180))||((round(double(max(Alat_new(:))))==90)&&(round(double(min(Alat_new(:))))==-90))
    tag=0;
else
    if (long<=max(Along_new(:)))&&(long>=min(Along_new(:)))&&(lat<=max(Alat_new(:)))&&(lat>=min(Alat_new(:)))
        %         diff=abs(long-Along)+abs(lat-Alat);
        %         diff=abs(long-Along_new)+abs(lat-Alat_new);
        diff=sqrt(power((long-Along_new),2)+power((lat-Alat_new),2));%��Ϊƽ����
        mindiff=min(diff(:));%��Ϊ����ֵ��--���ã�ǰ��diff�Ѿ���abs��
        %[row,col]=find(diff==mindiff);
        idx_lonlatnew=find(diff==mindiff);%
        minlon=Along_new(idx_lonlatnew);
        minlat=Alat_new(idx_lonlatnew);
        idx_min=intersect(find(Along==minlon(1)),find(Alat==minlat(1)));
        Along_arr=reshape(Along,n_row,n_col);
        [row1,col1]=find(Along_arr==Along(idx_min));
        
        Alat_arr=reshape(Alat,n_row,n_col);
        [row2,col2]=find(Alat_arr==Alat(idx_min));

        %%
        %         row=intersect(row1,row2);
        %         col=intersect(col1,col2);
        %         if find(row1==row) == find(col1==col)
        %             disp('ok');
        %         end
        
        uniq_row_col=intersect([row1,col1],[row2,col2],'rows');
        row=uniq_row_col(1);
        col=uniq_row_col(2);
        if size(uniq_row_col,1)~=1
            disp('�ҵ��������С����');
        end
        %%
        
        tag=1;%��С�������ֵ
        if (row==1)||(row==size(Along_arr,1))||(col==1)||(col==size(Along_arr,2))
            tag=0;
        end
    else
        tag=0;
    end
end
if tag==0
    row=0;
    col=0;
    mindiff=9999;
end
end