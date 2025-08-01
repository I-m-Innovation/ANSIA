function Data=ReadSanTeodoroData()

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/San_Teodoro/");

ST_tab=readtable("dati/San_Teodoro/201832_SanTeodoro.csv");

STpowers=ST_tab(string(ST_tab.VarName)=="Potenza_FTP",:);
STflow=ST_tab(string(ST_tab.VarName)=="Portata_FTP",:);
STpressure=ST_tab(string(ST_tab.VarName)=="Pressione_FTP",:);
Today=datetime("today","Format","dd/MM/uuuu");

ST_Time=STpowers.TimeString(STpowers.TimeString>=Today);
ST_Power=STpowers.VarValue(STpowers.TimeString>=Today);
ST_Flow=STflow.VarValue(STflow.TimeString>=Today);
ST_Flow=STflow.VarValue(STflow.TimeString>=Today);
ST_Pressure=STpressure.VarValue(STpressure.TimeString>=Today);

ST_Power=string(ST_Power);
ST_Power=strrep(ST_Power,',','.');
ST_Power=double(ST_Power);

ST_Flow=string(ST_Flow);
ST_Flow=strrep(ST_Flow,',','.');
ST_Flow=double(ST_Flow);

ST_Pressure=string(ST_Pressure);
ST_Pressure=strrep(ST_Pressure,',','.');
ST_Pressure=double(ST_Pressure);

firstOf2022=datetime('01/01/2022 00:00:00','Format','dd/MM/uuuu HH:mm:ss');
STYearlyFlow=STflow.VarValue(STflow.TimeString>=firstOf2022);
STYearlyFlow=string(STYearlyFlow);
STYearlyFlow=strrep(STYearlyFlow,',','.');
STYearlyFlow=double(STYearlyFlow);


FlowMean2022=mean(STYearlyFlow);

Data.timeStamp=ST_Time;
Data.Power=ST_Power;
Data.Flow=ST_Flow;
Data.Pressure=ST_Pressure;
Data.MeanFlow2022=FlowMean2022;

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

end