function Data=uploadTFData(app)

% creaNuovoDBTF(app);

host='192.168.10.211';
ftpobj=ftp(host, 'ftpdaticentzilio', 'Sd2PqAS.We8zBK');
mget(ftpobj,"dati/Torrino_Foresta/");

Tab=readtable("dati/Torrino_Foresta/DBTFNEW4.csv");
Time=datetime(Tab.Local,'InputFormat','dd/MM/uuuu HH:mm:ss','Format','dd/MM/uuuu HH:mm:ss');
Time=Time;
powers=string(Tab.PLC1_AI_POT_ATTIVA);
flow=string(Tab.PLC1_AI_FT_PORT_IST);
pressure=string(Tab.PLC1_AI_PT_TURBINA);
pressureOut = string(Tab.PLC1_AI_PT_TURBINA_OUT);
Today=datetime("today","Format","dd/MM/uuuu");
%Today=Today-'01:00:00';
Power=powers(Time>=Today);
Flow=flow(Time>=Today);
Pressure=pressure(Time>=Today);
PressureOut=pressureOut(Time>=Today);

Time2=Time(Time>=Today);

Power=string(Power);
Power=strrep(Power,',','.');
Power=double(Power);

Flow=string(Flow);
Flow=strrep(Flow,',','.');
Flow=double(Flow);

Pressure=string(Pressure);
Pressure=strrep(Pressure,',','.');
Pressure=double(Pressure);

PressureOut=string(PressureOut);
PressureOut=strrep(PressureOut,',','.');
PressureOut=double(PressureOut);


Time=datetime(Tab.Local,'InputFormat','dd/MM/uuuu HH:mm:ss','Format','dd/MM/uuuu HH:mm:ss');

firstOfTheYear="01/01/"+string(datetime('now','Format','uuuu'))+" 00:00:00";
firstOfTheYear=datetime(firstOfTheYear,'Format','dd/MM/uuuu HH:mm:ss');
Flow2023=flow(Time>=firstOfTheYear);

Flow2023=string(Flow2023);
Flow2023=strrep(Flow2023,',','.');
Flow2023=double(Flow2023);
FlowMean2023=mean(Flow2023);

Data.Producibile = [];%calcolaProducibile(Flow,Pressure); 
Data.timeStamp=Time2;
Data.Power=Power;
Data.Flow=Flow;
Data.Pressure=Pressure - PressureOut;
Data.MeanFlow2022=FlowMean2023;

%Data.NoLinkIntervals=findNoLink(app,Data,"PG");

Data.Fault=0;

end