function Data=uploadPPData()

DataST=uploadSTData();
DataPartitore=uploadPartitoreData();

A=2;

tST=datetime(DataST.timeStamp,"InputFormat","dd/MM/uuuu HH:mm:ss","Format","dd/MM/uuuu HH:mm:ss");
QST=DataST.Flow;
PST=DataST.Power;
hST=hour(max(tST));

tPartitore=datetime(DataPartitore.timeStamp,"InputFormat","dd/MM/uuuu HH:mm:ss","Format","dd/MM/uuuu HH:mm:ss");
QPartitore=DataPartitore.Flow;
PPartitore=DataPartitore.Power;


hPartitore=hour(max(tPartitore));
oraAttuale=hour(datetime("now"));
oraGrafici=min(hPartitore,hST);

tStart=datetime("today","Format","dd/MM/uuuu HH:mm:ss");

tStop=string(datetime("today","Format","dd/MM/uuuu"))+" 23:00:00";
tStop=datetime(tStop,"Format","dd/MM/uuuu HH:mm:ss");

Time=tStart:hours(1):tStop;
Time=Time(1:oraGrafici);

for i=1:oraGrafici

    QMeanST(i,1)=mean(QST(hour(tST)>=i-1 & hour(tST)<i));
    PMeanST(i,1)=mean(PST(hour(tST)>=i-1 & hour(tST)<i));

    QMeanPartitore(i,1)=mean(QPartitore(hour(tPartitore)>=i-1 & hour(tPartitore)<i));
    PMeanPartitore(i,1)=mean(PPartitore(hour(tPartitore)>=i-1 & hour(tPartitore)<i));
    
    Flow(i,1)=QMeanST(i,1)+QMeanPartitore(i,1);
    Power(i,1)=PMeanST(i,1)+PMeanPartitore(i,1);
end




Data.timeStamp=Time;
Data.Power=Power;
Data.Flow=Flow;
end