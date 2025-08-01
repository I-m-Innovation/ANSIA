function Data = RefreshData(app,Plant)

try
    app.FirstStart = 0;
    try
        switchStateLamp(app);
    catch err
        try
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'processswitchStateLamp()'"+newline+string(err.message);
%             sendmail2(Recipients,"viviL'OCCHIO: problema con la lampadina di stato",TEXT{:});
        end
    end
    try
        delete(app.errLabel);
    end

    if Plant=="HONDA"

        Type = "PV";

        try
            Data=processHonda(app,Plant);
        catch err
            try
                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'processHonda()'"+newline+string(err.message);
%                 sendmail2(Recipients,"viviL'OCCHIO: problema nel processamento dei dati",TEXT{:});
            end
        end



    elseif Plant=="3F"

        Type= "PV";

        try

            Data=process3F(app,Plant);

        catch err
            try

                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'process3F()'"+newline+string(err.message);
%                 sendmail2(Recipients,"viviL'OCCHIO: problema nel processamento dei dati",TEXT{:});

            end
        end

    end


    try

        refreshTimeLabel(app);

    catch err
        try

            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'refreshTimeLabel(app)'"+newline+string(err.message);
%             sendmail2(Recipients,"viviL'OCCHIO: problema con la timelabel",TEXT{:});
        end
    end

    try
        refreshEffText(app,Data,Plant);
    catch
        try
            refreshEffText(app,app.Data,app.Plant);
        catch err

            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'refreshTimeLabel(app)'"+newline+string(err.message);
%             sendmail2(Recipients,"viviL'OCCHIO: Problema con l'etichette di rendimento",TEXT{:});

        end
    end




catch errMain

    if isNew==1
        Recipients="stefano.trevisan@zilioservice.com";
        TEXT="Errore in 'refreshData()'"+newline+string(err.message);
%         sendmail2(Recipients,"viviL'OCCHIO: Problema Refresh dei dati",TEXT{:});

    end
end

try

    app.CurrData=Data;
    app.CurrPlant=Plant;

end
end