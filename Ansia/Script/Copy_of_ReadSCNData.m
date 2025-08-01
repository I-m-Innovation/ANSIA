function Data=ReadSCNData(app)

id=1032;
dev_id='2589LJTGI818';
logs_id='1042242';
power_id='1042242001';
irradiation_id='1042242009';
options1 = jsonencode(struct('username', 'ziliogroup', 'password','Yeeph4ue'));
opt=weboptions('Timeout',30);

Today=datetime("now",InputFormat="dd/MM/yyyy hh:mm");
if month(Today)>9
    Today_00=posixtime(datetime(day(Today)+"/"+month(Today)+"/"+year(Today)+" 00:00"));
else
    Today_00=posixtime(datetime(day(Today)+"/0"+month(Today)+"/"+year(Today)+" 00:00","InputFormat","d/MM/uuuu HH:mm"));

end


auth=webwrite('https://higeco-monitoraggio.it/api/v1/authenticate',options1,opt);
%                 B=webwrite('https://higeco-monitoraggio.it/api/v1/authenticate',app.Data.PV.WebOptions);
authToken=weboptions('KeyName','authorization','KeyValue',auth.token,'ContentType','json','Timeout',30);

TO=round(posixtime(datetime("now")));%-3600;

power=webread("https://higeco-monitoraggio.it/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+power_id+"?from="+Today_00+"&to="+TO,authToken);

irradiation=webread("https://higeco-monitoraggio.it/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+irradiation_id+"?from="+Today_00+"&to="+TO,authToken);

Data.irrTime=datetime(irradiation.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
Data.irrValue=irradiation.data(:,2);
Data.powTime=datetime(power.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
Data.powValue=power.data(:,2);

Eirr=0;
for i=1:length(Data.irrValue)-1
    Eirr=Eirr+mean([Data.irrValue(i),Data.irrValue(i+1)])*seconds(Data.irrTime(i+1)-Data.irrTime(i))/3600/1000; %kWh/m^2
end
Eprod=0;
for i=1:length(Data.powValue)-1
    Eprod=Eprod+mean([Data.powValue(i),Data.powValue(i+1)])*seconds(Data.powTime(i+1)-Data.powTime(i))/3600; %kW/m^2
end
Data.Eirr=Eirr;
Data.Eprod=Eprod;

end