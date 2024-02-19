%transformIDL，bloom extraction，b555_normalized，threshold0，rrc
datadir='E:\test0217\';
tiffOutFileBasePath='E:\test0217\';

filelist = dir([datadir,'A2013097050500.L2A_LAC_STD_sub']);
k=length(filelist);
for i=1:k
   ncFilePath = [datadir,filelist(i).name]; %设定NC路径
%---------------------------------------------------MERIS（多波段nc,有bug）
%    b_name=filelist(i).name(1:59);
%    %ncdisp(ncFilePath,'/', 'full');
%    lon=ncread(ncFilePath,'navigation_data/longitude');          %读取经度信息（范围、精度）
%    lat=ncread(ncFilePath,'navigation_data/latitude');          %读取维度信息
%    rrc=ncread(ncFilePath,'geophysical_data/Rrs');
%    %rrc=flipud(rrc');
%    R = georasterref('RasterSize', size(rrc(1,:,:)),'Latlim', [double(min(lat)) double(max(lat))], 'Lonlim', [double(min(lon)) double(max(lon))]);
%    modelpath=strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-2),'.tif');
%    geotiffwrite(modelpath,rrc,R);
%-------------------------------------------------MODIS(单波段nc)
   b_name=filelist(i).name(1:14);

   lon=ncread(ncFilePath,'navigation_data/longitude');          %读取经度信息（范围、精度）
   lat=ncread(ncFilePath,'navigation_data/latitude');          %读取维度信息
   rrc469=ncread(ncFilePath,'geophysical_data/rhos_469');
   rrc555=ncread(ncFilePath,'geophysical_data/rhos_555');
   rrc645=ncread(ncFilePath,'geophysical_data/rhos_645');
%    rrc859=ncread(ncFilePath,'geophysical_data/rhos_859');
%    rrc1240=ncread(ncFilePath,'geophysical_data/rhos_1240');
%    rrc1640=ncread(ncFilePath,'geophysical_data/rhos_1640');
   
   lon=flipud(lon');
   lat=flipud(lat');
%    rrc469=flipud(rrc469');
%    rrc555=flipud(rrc555');
%    rrc645=flipud(rrc645');
%    rrc859=flipud(rrc859');
%    rrc1240=flipud(rrc1240');
%    rrc1640=flipud(rrc1640');
   rrc469=rot90(rrc469,3);
   rrc555=rot90(rrc555,3);
   rrc645=rot90(rrc645,3);
%    rrc859=rot90(rrc859,3);
%    rrc1240=rot90(rrc1240,3);
%    rrc1640=rot90(rrc1640,3);
%    rrc(2,:,:)=rot90(rrc555,3);
%    rrc(3,:,:)=rot90(rrc645,3);
%    rrc(4,:,:)=rot90(rrc859,3);
%    rrc(5,:,:)=rot90(rrc1240,3);
%    rrc(1,:,:)=flipud(rrc(1,:,:)');
%    rrc(2,:,:)=flipud(rrc(2,:,:)');
%    rrc(3,:,:)=flipud(rrc(3,:,:)');
%    rrc(4,:,:)=flipud(rrc(4,:,:)');
%    rrc(5,:,:)=flipud(rrc(5,:,:)');

   R = georasterref('RasterSize', size(rrc469),'Latlim', [double(min(min(lat))) double(max(max(lat)))], 'Lonlim', [double(min(min(lon))) double(max(max(lon)))]);
   modelpath=strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-2),'469.tif');
   geotiffwrite(modelpath,rrc469,R);
   geotiffwrite(strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-2),'555.tif'),rrc555,R);
%    geotiffwrite(strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-2),'859.tif'),rrc859,R);
   geotiffwrite(strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-2),'645.tif'),rrc645,R);
%    geotiffwrite(strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-2),'1240.tif'),rrc1240,R);
%    geotiffwrite(strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-2),'1640.tif'),rrc1640,R);
%-------------------------------------------------MODIS(多波段nc)
%    b_name=filelist(i).name(1:14);
%    lon=ncread(ncFilePath,'navigation_data/longitude');          %读取经度信息（范围、精度）
%    lat=ncread(ncFilePath,'navigation_data/latitude');          %读取维度信息
%    rrc469=ncread(ncFilePath,'geophysical_data/rhos_1240');
%    rrc=rot90(rrc469,3);
%    %rrc469=rot90(rrc469,3);
%    %rrc555=rot90(rrc555,3);
%    %rrc645=rot90(rrc645,3);
%    %rrc=flipud(rrc');
% 
%    R = georasterref('RasterSize', size(rrc),'Latlim', [double(min(min(lat))) double(max(max(lat)))], 'Lonlim', [double(min(min(lon))) double(max(max(lon)))]);
%    modelpath=strcat(tiffOutFileBasePath,filelist(i).name(1:find(filelist(i).name=='n')-11),'1240.tif');
%    geotiffwrite(modelpath,rrc,R);
end