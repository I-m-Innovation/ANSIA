function     Data=processHonda(app,Plant)

try
    delete(app.errLabel)
end

try
    if app.Resize == 0

        try
            Data = uploadHondaData(app);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'uploadHONDAData()'"+newline+string(err.message);
            %             sendmail2(Recipients,"viviL'OCCHIO: problema con l'upload dei dati (Honda)",TEXT{:});
        end


        if isempty(Data.PowerAC)
            isEmpty =1;
        else
            isEmpty=0;
        end

        try


            plotPV(app,Data,Plant,isEmpty);

        catch err2
            B=2;
            try

                plotPV(app,app.CurrData,Plant,isEmpty);
            catch err
                B=2;
            end

            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotPV(app,Data)'"+newline+string(err.message);
            %             sendmail2(Recipients,"viviL'OCCHIO: problema con il plot dei dati (Honda)",TEXT{:});
        end
        app.CurrData=Data;

    else

        Data=app.CurrData;
        if isempty(Data.PowerAC)
            isEmpty =1;
        else
            isEmpty=0;
        end

        try
            plotPV(app,app.CurrData,Plant,isEmpty);
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'plotPV(app,app.CurrData)'"+newline+string(err.message);
            %             sendmail2(Recipients,"viviL'OCCHIO: problema con il REplot dei dati (Honda)",TEXT{:});
        end
        app.Resize = 0;

    end

    app.NErr(:)=zeros(length(app.NErr));

    try
        changeStateLampStatus(app,'green',"online");
    catch err
        try

            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'processswitchStateLamp()'"+newline+string(err.message);
            %             sendmail2(Recipients,"viviL'OCCHIO: problema con la lampadina di stato",TEXT{:});

        end

    end


catch err

    if err.message=="The connection to URL 'https://higeco-monitoraggio.it/api/v1/authenticate' timed out after 60.000 seconds. The reason is "+char(34)+"Waiting for response header"+char(34)+". Perhaps the server is not responding or weboptions.Timeout needs to be set to a higher value." && app.NErr(1)<=5
        try
            app.ErrCode=1;
            app.NErr(app.ErrCode)=app.NErr(app.ErrCode)+1;
            app.ConnectionstateLamp.Visible='on';
            changeStateLampStatus(app,[0.9290 0.6940 0.1250],"Warning");
        catch err1
            try

                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'processswitchStateLamp()'"+newline+string(err1.message);
                %                 sendmail2(Recipients,"viviL'OCCHIO: problema con la lampadina di stato",TEXT{:});

            end
        end
    else
        try
            printError(app,err);
        catch err1
            try

                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'printError()'"+newline+string(err1.message);
                %                 sendmail2(Recipients,"viviL'OCCHIO: problema con la stampa dell'errore",TEXT{:});

            end
        end
        Obj="DEBUG OCCHIO - "+string(Plant);
        %         sendmail2('stefano.trevisan@zilioservice.com',Obj{:},err.message);
        app.ConnectionstateLamp.Visible='on';

        try
            changeStateLampStatus(app,'red',"Error");
        catch err2
            try

                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'processswitchStateLamp()'"+newline+string(err2.message);
                %                 sendmail2(Recipients,"viviL'OCCHIO: problema con la lampadina di stato",TEXT{:});

            end

        end

    end

end

try
    app.CurrData=Data;
    app.CurrPlant=Plant;

end

end