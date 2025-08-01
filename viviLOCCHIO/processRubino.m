function Data = processRubino(app,Plant)


try

    try
        delete(app.errLabel);
    end

    if app.Resize==0
        try
            Data=uploadRubinoData(app);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'uploadRubinoData()'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
        try
            plotPV(app,Data);
        catch err

            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotPV(app,Data)'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
    else
        try
            plotPV(app,app.CurrData);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotPV(app,app.CurrData)'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
        Data=app.CurrData;

        app.Resize=0;

    end

    Type="PV";
    app.NErr(:)=zeros(length(app.NErr));
    changeStateLampStatus(app,'green',"online");

catch err

    if err.message=="The connection to URL 'https://higeco-monitoraggio.it/api/v1/authenticate' timed out after 60.000 seconds. The reason is "+char(34)+"Waiting for response header"+char(34)+". Perhaps the server is not responding or weboptions.Timeout needs to be set to a higher value." && app.NErr(1)<=5

        app.ErrCode=1;
        app.NErr(app.ErrCode)=app.NErr(app.ErrCode)+1;
        app.ConnectionstateLamp.Visible='on';
        changeStateLampStatus(app,[0.9290 0.6940 0.1250],"Warning");

    else
        printError(app,err);
        Obj="DEBUG OCCHIO - "+string(Plant);
        sendmail2('stefano.trevisan@zilioservice.com',Obj{:},err.message);
        app.ConnectionstateLamp.Visible='on';
        changeStateLampStatus(app,'red',"Error");

    end

end

try
    app.CurrPlant=Plant;
    app.CurrData=Data;

end
end