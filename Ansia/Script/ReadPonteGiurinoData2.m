function Data=ReadPonteGiurinoData(app)

%creaNuovoDB();

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
mget(ftpobj,"dati/ponte_giurino/");


Tab=readtable("dati/ponte_giurino/PGlast24hTL.csv");
Time=datetime(Tab.t);%,'uuuu-MM-dd HH:mm:ss','Format','dd/MM/uuuu HH:mm:ss');
Power=Tab.P;
Flow=Tab.Q;
Pressure = Tab.Bar;

Today=datetime("today","Format","dd/MM/uuuu");

Power = Power(Time>=Today);
Flow = Flow(Time>=Today);
Pressure = Pressure(Time>=Today);
Time = Time(Time>=Today);

Tab=readtable("dati/ponte_giurino/QMediaAnno.csv");
Flow2023=Tab.QMediaAnno;

Data.timeStamp=Time;
Data.Power=Power;
Data.Flow= 1000 * Flow;
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