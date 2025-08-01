function Data = processRubino(app,Plant)


try

    try
        delete(app.errLabel);
    end

    if app.Resize==0
        try
            Data=uploadRubinoData(app);
        catch err
            err
        end
        try
            plotPV(app,Data);
        catch err

            err
        end



    else
        try
            plotPV(app,app.CurrData);
        catch err
            err
        end
        Data=app.CurrData;

        app.Resize=0;

    end

    Type="PV";
    app.NErr(:)=zeros(length(app.NErr));

catch err

    if err.message=="The connection to URL 'https://higeco-monitoraggio.it/api/v1/authenticate' timed out after 60.000 seconds. The reason is "+char(34)+"Waiting for response header"+char(34)+". Perhaps the server is not responding or weboptions.Timeout needs to be set to a higher value." && app.NErr(1)<=5

        app.ErrCode=1;
        app.NErr(app.ErrCode)=app.NErr(app.ErrCode)+1;

    else
        err

    end

end
plotNoLink(app,Data,"Rubino");
hold(app.Graph,'off');

try
    app.CurrPlant=Plant;
    app.CurrData=Data;

end
end