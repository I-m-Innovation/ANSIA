function Data=uploadPGData(app)

%creaNuovoDB(app);

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/ponte_giurino/");

Tab=readtable("dati/ponte_giurino/PGlast24hTL.csv");
Time=datetime(Tab.t); %,'InputFormat','dd/MM/uuuu HH:mm:ss','Format','dd/MM/uuuu HH:mm:ss');
Power=Tab.P;
Flow=Tab.Q;
Pressure = Tab.Bar;

Today=datetime("today","Format","dd/MM/uuuu");

Tab=readtable("dati/ponte_giurino/QMediaAnno.csv");
Flow2023=Tab.QMediaAnno;

Data.timeStamp=Time;
Data.Power=Power;
Data.Flow=1000*Flow;
Data.Pressure=Pressure;
Data.MeanFlow2022=Flow2023;

if isempty(Power)==0

    Data.Fault=0;

else

    Data.Fault=1;

end

%Data.NoLinkIntervals=findNoLink(app,Data,"PG");

end
