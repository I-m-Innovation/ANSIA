function Data=ReadPonteGiurinoData(app)

creaNuovoDB();

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/ponte_giurino/");

ST_tab=readtable("dati/ponte_giurino/provaDB.csv");
ST_Time=datetime(ST_tab.x__TimeStamp,'InputFormat','dd/MM/uuuu hh:mm:ss');
STpowers=string(ST_tab.PLC1_AI_POT_ATTIVA);
STflow=string(ST_tab.PLC1_AI_FT_PORT_IST);
STpressure=string(ST_tab.PLC1_AI_PT_TURBINA);
Today=datetime("today","Format","dd/MM/uuuu");
Today=Today-'02:00:00';
ST_Power=STpowers(ST_Time>=Today);
ST_Flow=STflow(ST_Time>=Today);
ST_Pressure=STpressure(ST_Time>=Today);
ST_Time=ST_Time(ST_Time>=Today);
ST_Time=ST_Time+'02:00:00';

ST_Power=string(ST_Power);
ST_Power=strrep(ST_Power,',','.');
ST_Power=double(ST_Power);

ST_Flow=string(ST_Flow);
ST_Flow=strrep(ST_Flow,',','.');
ST_Flow=double(ST_Flow);

ST_Pressure=string(ST_Pressure);
ST_Pressure=strrep(ST_Pressure,',','.');
ST_Pressure=double(ST_Pressure);


Data.timeStamp=ST_Time;
Data.Power=ST_Power;
Data.Flow=ST_Flow;
Data.Pressure=ST_Pressure;

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