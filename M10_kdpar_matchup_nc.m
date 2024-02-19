%一 二 三 分别去掉注释就可以运行
clc;
clear;

path='E:\Rrs_validation_Gloria\Modis_aqua_20230823\';


% satellite_files
[~,filelist]=xlsread(strcat(path,'insitu_spectral1.xls'),'satellite_files');%satellite filelist
path_satellite='Z:\data\modis_gloria_std\';

% Rrs
[insitu_rrs_old,head0]=xlsread(strcat(path,'insitu_spectral1.xls'),'Sheet1');

insitu_date = insitu_rrs_old(2:end,1:6);
insitu_rrs = insitu_rrs_old(2:end,7:16);

time_col = zeros(size(insitu_date, 1), 1);
for k = 1:size(insitu_date, 1)
    time_col(k) = insitu_date(k, 5)*60 + insitu_date(k, 6);
end
insitu_date = [insitu_date, time_col];

matchups=zeros(0,30);%5date + lon + lat + 11Rrs_insitu+ 10Rrs_satellite + row+col+lon+lat=32
for i=1:size(filelist,1)%循环images
    fname=filelist{i,1};
    if exist(strcat(path_satellite,fname),'file')
        lats=ncread(strcat(path_satellite,fname),'navigation_data/latitude');
        lons=ncread(strcat(path_satellite,fname),'navigation_data/longitude');
        Alonglat=cat(1,(lons(:))',(lats(:))');%行存储image的lon lat
    
        % read l2flags
        l2flags=ncread(strcat(path_satellite,fname),'geophysical_data/l2_flags');
        idx_flags_bad=bitand(l2flags,int32(2)^9); % cloud
        idx_flags_bad=bitor(idx_flags_bad,bitand(l2flags,int32(2)^8)); % straylight
        idx_flags_bad=bitor(idx_flags_bad,bitand(l2flags,int32(2)^12)); % hight sol zen
        idx_flags_bad=bitor(idx_flags_bad,bitand(l2flags,int32(2)^5)); % hight sat zen
        l2flags_good=ones(size(l2flags,1),size(l2flags,2));
        l2flags_good(find(idx_flags_bad))=nan;
    
        % read Rrs410
        rrs_412=zeros(size(l2flags,1),size(l2flags,2));
        rrs_412=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_412');
        rrs_412=rrs_412.*l2flags_good;
        % read Rrs443
        rrs_443=zeros(size(l2flags,1),size(l2flags,2));
        rrs_443=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_443');
        rrs_443=rrs_443.*l2flags_good;
        % read Rrs469
        rrs_469=zeros(size(l2flags,1),size(l2flags,2));
        rrs_469=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_469');
        rrs_469=rrs_469.*l2flags_good;
        % read Rrs486
        rrs_488=zeros(size(l2flags,1),size(l2flags,2));
        rrs_488=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_488');
        rrs_488=rrs_488.*l2flags_good;
        % read Rrs551
        rrs_531=zeros(size(l2flags,1),size(l2flags,2));
        rrs_531=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_531');
        rrs_531=rrs_531.*l2flags_good;
        % read Rrs547
        rrs_547=zeros(size(l2flags,1),size(l2flags,2));
        rrs_547=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_547');
        rrs_547=rrs_547.*l2flags_good;
        % read Rrs555
        rrs_555=zeros(size(l2flags,1),size(l2flags,2));
        rrs_555=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_555');
        rrs_555=rrs_555.*l2flags_good;
        % read Rrs645
        rrs_645=zeros(size(l2flags,1),size(l2flags,2));
        rrs_645=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_645');
        rrs_645=rrs_645.*l2flags_good;
        % read Rrs667
        rrs_667=zeros(size(l2flags,1),size(l2flags,2));
        rrs_667=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_667');
        rrs_667=rrs_667.*l2flags_good;
        % read Rrs678
        rrs_678=zeros(size(l2flags,1),size(l2flags,2));
        rrs_678=ncread(strcat(path_satellite,fname),'geophysical_data/Rrs_678');
        rrs_678=rrs_678.*l2flags_good;
       
        % find time match
        yy=str2num(fname(1,2:5));
        doy=str2num(fname(1,6:8)); 
        hh=str2num(fname(1,9:10));
        mm=str2num(fname(1,11:12));
        % filter by date and time
        idx_date=intersect(find(insitu_date(:,3)==yy),find(insitu_date(:,4)==doy));
        idx_date=intersect(find(insitu_date(:,7) >= (hh * 60 + mm - 90)),idx_date);
        idx_date=intersect(find(insitu_date(:,7) <= (hh * 60 + mm + 90)),idx_date);
        
        for j=1:length(idx_date)%循环符合要求的实测点
            i_situ=idx_date(j);
            lon=insitu_date(i_situ,2);
            lat=insitu_date(i_situ,1);
            date_insitu=insitu_date(i_situ,3:6); %4 column
            rrs_insitu_412_678=insitu_rrs(i_situ,:); %10 column
            %read satellite images
            [row,col,mindiff] = Func_lonlat2Rowcol_2_1hang2(lon,lat,Alonglat,size(lats,1),size(lats,2));
            if (row~=0)&&(col~=0)
                % get Rrs412-678 by ExtractPointValue_rrs
                mean_tag_std_cv_num1=Func_ExtractPointValue_rrs(row,col,rrs_412);
                mean_tag_std_cv_num2=Func_ExtractPointValue_rrs(row,col,rrs_443);
                mean_tag_std_cv_num3=Func_ExtractPointValue_rrs(row,col,rrs_469);
                mean_tag_std_cv_num4=Func_ExtractPointValue_rrs(row,col,rrs_488);
                mean_tag_std_cv_num5=Func_ExtractPointValue_rrs(row,col,rrs_531);
                mean_tag_std_cv_num6=Func_ExtractPointValue_rrs(row,col,rrs_547);
                mean_tag_std_cv_num7=Func_ExtractPointValue_rrs(row,col,rrs_555);
                mean_tag_std_cv_num8=Func_ExtractPointValue_rrs(row,col,rrs_645);
                mean_tag_std_cv_num9=Func_ExtractPointValue_rrs(row,col,rrs_667);
                mean_tag_std_cv_num10=Func_ExtractPointValue_rrs(row,col,rrs_678);
    
                % get the point Rrs_array
                Rrs_modis_412_671=[mean_tag_std_cv_num1(1),mean_tag_std_cv_num2(1),mean_tag_std_cv_num3(1),mean_tag_std_cv_num4(1),mean_tag_std_cv_num5(1),mean_tag_std_cv_num6(1),mean_tag_std_cv_num7(1),mean_tag_std_cv_num8(1),mean_tag_std_cv_num9(1),mean_tag_std_cv_num10(1)];
                num_tmp=[mean_tag_std_cv_num1(end),mean_tag_std_cv_num2(end),mean_tag_std_cv_num3(end),mean_tag_std_cv_num4(end),mean_tag_std_cv_num5(end),mean_tag_std_cv_num6(end),mean_tag_std_cv_num7(end),mean_tag_std_cv_num8(end),mean_tag_std_cv_num9(end),mean_tag_std_cv_num10(end)];
                cv_tmp = [mean_tag_std_cv_num1(4),mean_tag_std_cv_num2(4),mean_tag_std_cv_num3(4),mean_tag_std_cv_num4(4),mean_tag_std_cv_num5(4),mean_tag_std_cv_num6(4),mean_tag_std_cv_num7(4),mean_tag_std_cv_num8(4),mean_tag_std_cv_num9(4),mean_tag_std_cv_num10(4)];
                % if 3x3 windows num < 5 
                idx_tmp = find(num_tmp<5);
                Rrs_modis_412_671(idx_tmp) = 0;
                % if 3x3 windows cv > 0.15
                idx_tmp = find(cv_tmp>0.15);
                Rrs_modis_412_671(idx_tmp) = 0;
    
                matchup_point_lat=lats(row,col);
                matchup_point_lon=lons(row,col);
            else
                Rrs_modis_412_671=zeros(1,10);
                
                matchup_point_lat=9999;
                matchup_point_lon=9999;
            end
            matchups=cat(1,matchups,[date_insitu,lon,lat,rrs_insitu_412_678,Rrs_modis_412_671,row,col,matchup_point_lon,matchup_point_lat]);
            
        end
    end
end
idx=find(matchups==0);
tmppp=matchups;
tmppp(idx)=NaN;
header={'year','doy','hour','minute','lon','lat','insitu_Rrs412','insitu_Rrs443','insitu_Rrs469','insitu_Rrs488','insitu_Rrs531','insitu_Rrs547','insitu_Rrs555','insitu_Rrs645','insitu_Rrs667','insitu_Rrs678','Rrs412','Rrs443','Rrs469','Rrs488','Rrs531','Rrs547','Rrs555','Rrs645','Rrs667','Rrs678','row','col','lon','lat'};
xlswrite(strcat(path,'result_500m_std_15h.xlsx'),cat(1,header,num2cell(tmppp)),'Sheet1');
