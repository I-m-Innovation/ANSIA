function    BlockData=EnergyData(STData,PARData)

    A=1;
    t0=datetime("today","Format","dd/MM/uuuu HH:mm:ss");
    tF=datetime("now","Format","dd/MM/uuuu HH:mm:ss");
    
    STTime=STData.timeStamp;
    STPower=STData.Power;

    PARTime=PARData.timeStamp;
    PARPower=PARData.Power;

    tCurr=t0;

%   Ogni volta che refresha ->
    %   Calcolo l'energia prodotta in quell'ora da entrambe le centrali
    %   ne costituisco i blocchi

    j=1;
    Nh=hour(tF)+1;
    i=1;
    while tCurr<tF
        
        STEnergy=mean(STPower(STTime>=tCurr & STTime<tCurr+hours(1)));
        PAREnergy=mean(PARPower(PARTime>=tCurr & PARTime<tCurr+hours(1)));

        if i==Nh
            STEnergy=STEnergy*minute(datetime('now'))/60;
             PAREnergy=PAREnergy*minute(datetime('now'))/60;
           
        end

        BlockData(i,:)=[STEnergy,PAREnergy];
        i=i+1;
        tCurr=tCurr+hours(1);

    end
    


end