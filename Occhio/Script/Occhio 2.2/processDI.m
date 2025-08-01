function Data=processDI(app,Plant)

try
    try
        delete(app.errLabel);
    end

    if app.Resize==0
        try
            Data=uploadHSIData(app);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'uploadHSIData()'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
        try
            plotHSI(app,Data);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotHSI(app,Data)'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end

    else
        try
            plotHSI(app,app.CurrData);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotHSI(app,app.CurrData)'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
        Data=app.CurrData;
        app.Resize=0;

    end
catch err
    printError(app,err);
    Obj="DEBUG OCCHIO - "+string(Plant);
    try
        sendmail2('stefano.trevisan@zilioservice.com',Obj{:},err.message);
    catch err
        printError(app,err);
    end
end
end