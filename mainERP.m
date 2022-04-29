pathST='C:\Users\coco1\Documents\Tesis\Procesamiento\ACU\ACUGC\Acu_0';
pathAP='C:\Users\coco1\Documents\Tesis\Procesamiento\ACU\ACUGC\ERPap';
for acu=1:4
pathSET=[pathST,num2str(acu)];
Ld=Get_List(pathSET,'*.gdf');
for p=1:length(Ld)
nameSET=Ld{p}; 
mkdir(pathAP,['\' replace(nameSET,['_Acu_0',num2str(acu),'.gdf'],'')]);
pathOUT=[pathAP,'\' replace(nameSET,['_Acu_0',num2str(acu),'.gdf'],'')];
pathERP=[pathSET '\' replace(nameSET,'.gdf','')];
nameERP=[replace(nameSET,'.gdf','') 'WICA' 'epoch.set'];
EEGerp=ERPst(nameERP,pathERP,pathOUT);
end
end
%%
[a,b,c,d,e,f,g,h,cohsig]= erpimage(EEG.data(ch,:,:),[],...
        -199:1000/EEG.srate:799,nameERP,1,1,'srate',EEG.srate,...
                                'coher',[8 13 0.1], 'erp','off');