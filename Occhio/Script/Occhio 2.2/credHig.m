clc
clear all
close all

id=1032;
dev_id='2589LJTGI818';
logs_id='1042242';

options1 = jsonencode(struct('username', 'ziliogroup', 'password','Yeeph4ue'));
opt=weboptions('Timeout',60);

[FROM, TO]=DaysExtremes();

auth=webwrite('https://higeco-monitoraggio.it/api/v1/authenticate',options1,opt);
authToken=weboptions('KeyName','authorization','KeyValue',auth.token,'ContentType','json','Timeout',30);

Temp=webread("https://higeco-monitoraggio.it/api/v1/plants/"+id+"/devices/"+dev_id+"/logs/"+logs_id+"/items",authToken);
