function EffLab(app,Data,Type,Plant)

if Plant~= "Zilio Group 20 kW"
    try
        refreshEffLabel(app,Data,Type,Plant);
    catch err


        try
            refreshEffLabel(app,app.Data,Type,Plant);
        catch err
            try
            isNew=identifyError(err,"refreshEffLabel");

            if isNew==1
                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'refreshEffLabel(app,Data,Type,Plant)'"+newline+string(err.message);
                sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
                isNew=0;
            end
            end
        end
    end

end

end