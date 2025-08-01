function Data=uploadSA3Data(app)

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/SA3/");

InputTab=readtable("dati/SA3/201905_SA3.csv");

powers=InputTab.Leistung;
flow=InputTab.Durchfluss;
pressure=InputTab.DruckEingang;
Today=datetime("today","Format","dd/MM/uuuu");

Time=InputTab.LocalCol;
Power=powers(Time>=Today);
Flow=flow(Time>=Today);
Flow=flow(Time>=Today);
Pressure=pressure(Time>=Today);

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
YearlyFlow=flow(Time>=firstOfTheYear);
YearlyFlow=string(YearlyFlow);
YearlyFlow=strrep(YearlyFlow,',','.');
YearlyFlow=double(YearlyFlow);

%Data.Producibile = calcolaProducibile(Flow,Pressure); 

FlowMean2023=mean(YearlyFlow);

Time = Time(Time>=Today);
Data.timeStamp=Time;
Data.Power=Power;
Data.Flow=Flow;
Data.Pressure=Pressure;
Data.MeanFlow2022=FlowMean2023;
Data.Fault=0;

Data.NoLinkIntervals=findNoLink(app,Data,"SA3");

end