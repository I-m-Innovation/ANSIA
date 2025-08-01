function Status=evaluateStatus(app,Data,Plant)

changeStateLampStatus(app,'green');

if Plant=="SCN - Pilota"
    
    lastPTOT=Data.PTot(end);
    lastP1=Data.P1(end);
    lastP2=Data.P2(end);
    lastI=Data.irrValue(end);
    
    if lastI<100
      changeStateLampStatus(app,[.7 .7 .7]);
  
    else

    if lastPTOT==0 || lastP1==0 || lastP2==0
        
        changeStateLampStatus(app,'r');

    end
    end

elseif Plant=="Rubino"

    lastP=Data.powValue(end);
    lastI=Data.irrValue(end);
   
    if lastI==0
      changeStateLampStatus(app,[.7 .7 .7]);
        
    else

    if lastP<1
        changeStateLampStatus(app,'r');

    end
    end
elseif Plant=="Ponte Giurino" || Plant=="San Teodoro" || Plant=="Partitore"

    if isempty(Data.Power)==0
    lastP=Data.Power(end);
    if lastP==0
        changeStateLampStatus(app,'r');
    end
    else
        changeStateLampStatus(app,[0.9290 0.6940 0.1250]);
        
    end
else
    lastP=Data(end,:);
    if lastP(1)==0 || lastP(2)==0
        changeStateLampStatus(app,'r');
    end
end