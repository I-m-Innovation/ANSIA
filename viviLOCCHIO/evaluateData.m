function status=evaluateData(Data)

    lastTime=Data.TimeString;
    lastDC=Data.DCPowers(end);
    status="OK";

    if lastDC==0

        status="FERMO";

    elseif isnan(lastDC)== 1

        if minutes(datetime('now')-lastTime)>20
            status="NOLINK";
        end
    end


end