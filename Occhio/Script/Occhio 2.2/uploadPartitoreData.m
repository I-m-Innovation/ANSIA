function Data=uploadPartitoreData(app)

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/San_Teodoro/");

File="dati/San_Teodoro/201833_Partitore.csv";
opts = detectImportOptions(File);
opts = setvartype(opts, "VarValue", 'string');
Tab=readtable("dati/San_Teodoro/201833_Partitore.csv",opts);

powers=Tab(string(Tab.VarName)=="Potenza_FTP",:);
flow=Tab(string(Tab.VarName)=="Portata_FTP",:);
pressure=Tab(string(Tab.VarName)=="Pressione_FTP",:);
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

STYearlyFlow=flow.VarValue(flow.TimeString>=firstOfTheYear);
STYearlyFlow=string(STYearlyFlow);
STYearlyFlow=strrep(STYearlyFlow,',','.');
STYearlyFlow=double(STYearlyFlow);

FlowMean2023=mean(STYearlyFlow);
%Data.Producibile = calcolaProducibile(Flow,Pressure); 

Data.Fault=0;
Data.timeStamp=Time;
Data.Power=Power;
Data.Flow=Flow;
Data.Pressure=Pressure;
Data.MeanFlow2022=FlowMean2023;
Data.NoLinkIntervals=findNoLink(app,Data,"PAR");

end