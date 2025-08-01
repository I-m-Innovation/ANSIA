function Data=processPP(app,Plant)

app.CurrPlant=Plant;

try
    delete(app.errLabel)
end

try
    if app.Resize==0
        try
            STData=uploadSTData(app);
            PARData=uploadPartitoreData(app);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'uploadSTData()'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end

        try

            Data=EnergyData(STData,PARData);
            plotBlock(app,Data);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotIdro()'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end

    else

        try
            plotBlock(app,app.CurrData);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotIdro()'"+newline+string(err.message);
            sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
        Data=app.CurrData;
        app.Resize=0;

    end

%     app.NErr(:)=zeros(length(app.NErr));


catch err

    if err.message=="FTP error: 426. See FTP server return codes for more information." && app.NErr(1)<=5


        app.ErrCode=1;
        app.NErr(app.ErrCode)=app.NErr(app.ErrCode)+1;


    else

        printError(app,err);

        Obj="DEBUG OCCHIO - "+string(Plant);
        sendmail2('stefano.trevisan@zilioservice.com',Obj{:},err.message);


    end

end
