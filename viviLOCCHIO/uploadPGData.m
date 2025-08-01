function Data=uploadPGData(app)

DBCleaner(app);

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/ponte_giurino/");

Tab=readtable("dati/ponte_giurino/DBPG.csv");
Time=datetime(Tab.x__TimeStamp,'InputFormat','dd/MM/uuuu hh:mm:ss');
powers=string(Tab.PLC1_AI_POT_ATTIVA);
flow=string(Tab.PLC1_AI_FT_PORT_IST);
pressure=string(Tab.PLC1_AI_PT_TURBINA);
Today=datetime("today","Format","dd/MM/uuuu");
Today=Today-'02:00:00';
Power=powers(Time>=Today);
Flow=flow(Time>=Today);
Pressure=pressure(Time>=Today);
Time=Time(Time>=Today);
Time=Time+'02:00:00';

Power=string(Power);
Power=strrep(Power,',','.');
Power=double(Power);

Flow=string(Flow);
Flow=strrep(Flow,',','.');
Flow=double(Flow);

Pressure=string(Pressure);
Pressure=strrep(Pressure,',','.');
Pressure=double(Pressure);

firstOf2022=datetime('01/01/2022 00:00:00','Format','dd/MM/uuuu HH:mm:ss');
Flow2022=flow(Time>=firstOf2022);
Flow2022=string(Flow2022);
Flow2022=strrep(Flow2022,',','.');
Flow2022=double(Flow2022);
FlowMean2022=mean(Flow2022);


Data.timeStamp=Time;
Data.Power=Power;
Data.Flow=Flow;
Data.Pressure=Pressure;
Data.MeanFlow2022=FlowMean2022;

end