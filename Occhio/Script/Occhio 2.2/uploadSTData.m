function Data=uploadSTData(app)

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/San_Teodoro/");

InputTab=readtable("dati/San_Teodoro/201832_SanTeodoro.csv");

powers=InputTab(string(InputTab.VarName)=="Potenza_FTP",:);
flow=InputTab(string(InputTab.VarName)=="Portata_FTP",:);
pressure=InputTab(string(InputTab.VarName)=="Pressione_FTP",:);
Today=datetime("today","Format","dd/MM/uuuu");

Time=powers.TimeString(powers.TimeString>=Today);
Power=powers.VarValue(powers.TimeString>=Today);
Flow=flow.VarValue(flow.TimeString>=Today);
Flow=flow.VarValue(flow.TimeString>=Today);
Pressure=pressure.VarValue(pressure.TimeString>=Today);

Power=string(Power);
Power=strrep(Power,',','.');
Power=double(Power);

Flow=string(Flow);
Flow=strrep(Flow,',','.');
Flow=double(Flow);

Pressure=string(Pressure);
Pressure=strrep(Pressure,',','.');
Pressure=double(Pressure);

firstOfTheYear="01/01/"+string(datetime('now','Format','uuuu'))+" 00:00:00";
firstOfTheYear=datetime(firstOfTheYear,'Format','dd/MM/uuuu HH:mm:ss');
YearlyFlow=flow.VarValue(flow.TimeString>=firstOfTheYear);
YearlyFlow=string(YearlyFlow);
YearlyFlow=strrep(YearlyFlow,',','.');
YearlyFlow=double(YearlyFlow);

%Data.Producibile = calcolaProducibile(Flow,Pressure); 

FlowMean2023=mean(YearlyFlow);

Data.timeStamp=Time;
Data.Power=Power;
Data.Flow=Flow;
Data.Pressure=Pressure;
Data.MeanFlow2022=FlowMean2023;
Data.Fault=0;

Data.NoLinkIntervals=findNoLink(app,Data,"ST");

end