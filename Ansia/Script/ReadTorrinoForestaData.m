function Data=ReadTorrinoForestaData()

%creaNuovoDBTF(app);

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/Torrino_Foresta/");

Tab=readtable("dati/Torrino_Foresta/DBTFNEW5.csv");
Time=datetime(Tab.Local,'InputFormat','dd/MM/uuuu HH:mm:ss','Format','dd/MM/uuuu HH:mm:ss');
% Time=Time+'02:00:00';
powers=string(Tab.PLC1_AI_POT_ATTIVA);
flow=string(Tab.PLC1_AI_FT_PORT_IST);
pressure=string(Tab.PLC1_AI_PT_TURBINA);
Today=datetime("today","Format","dd/MM/uuuu");
%Today=Today-'01:00:00';
Power=powers(Time>=Today);
Flow=flow(Time>=Today);
Pressure=pressure(Time>=Today);
Time=Time(Time>=Today);

Power=string(Power);
Power=strrep(Power,',','.');
Power=double(Power);

Flow=string(Flow);
Flow=strrep(Flow,',','.');
Flow=double(Flow);

Pressure=string(Pressure);
Pressure=strrep(Pressure,',','.');
Pressure=double(Pressure);


Data.timeStamp=Time;
Data.Power=Power;
Data.Flow=Flow;
Data.Pressure=Pressure;

Vol=0;
Q=Data.Flow;
P=Data.Power;
E=0;

for i=1:length(Data.timeStamp)-1
    
    dt=seconds(Data.timeStamp(i+1)-Data.timeStamp(i));
    Vol=Vol+dt*mean([Q(i) Q(i+1)]);
    E=E+dt*mean([P(i+1),P(i)])/3600;

end

Data.VolumeDerivato=Vol;
Data.Eprod=E;