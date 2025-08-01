function NoLinkIntervals=findNoLink(app,InputData,Sec)

if Sec=="SCN" || Sec=="PG" || Sec=="ST" || Sec=="PAR" || Sec=="SA3"

    if InputData.Fault==0
        timeStamps=InputData.timeStamp;
    else
        timeStamps=[];
    end

elseif Sec=="SCN1"

    if InputData.Fault==0
        timeStamps=InputData.T1;
    else
        timeStamps=[];

    end

elseif Sec=="Rubino"

    timeStamps=InputData.powTime;
    dt=15;

elseif Sec=="SCN2"
if InputData.Fault==0
    timeStamps=InputData.T2;
else
    timeStamps=[];
end
end

N=length(timeStamps);
nFermi=0;

if N>1
    for i=1:N-1 %   ciclo per trovare vuoti di campionamento

        curr=timeStamps(i);
        next=timeStamps(i+1);
        now=datetime("now");


        if minutes(next-curr)>20    % se due dati distano più di 20 minuti allora lo classifico come fermo

            nFermi=nFermi+1;
            onset(nFermi,1)=curr;
            offset(nFermi,1)=next;

        end
    end


    if minutes(datetime("now")-next)>20 %   se l'ultimo campione ha un ritardo maggiore di venti minuti lo classifico come fermo

        nFermi=nFermi+1;
        onset(nFermi,1)=next;
        offset(nFermi,1)=datetime("now");
        changeStateLampStatus(app,[0.9290 0.6940 0.1250]);

    end

elseif N==1

    curr=timeStamps(1);
    onset=curr;
    offset=datetime('now');

else
    onset=datetime('today');
    offset=datetime('now');

end


try
    NoLinkIntervals=[onset offset];
catch
    NoLinkIntervals=[];
end
