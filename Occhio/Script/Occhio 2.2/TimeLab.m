function TimeLab(app)
try

    refreshTimeLabel(app);
    
catch err

    isNew=identifyError(err,"refreshTimeLabel");

    if isNew==1

        Recipients="stefano.trevisan@zilioservice.com";
        TEXT="Errore in 'refreshTimeLabel(app,app.Data,app.Type,app.Plant)'"+newline+string(err.message);
        sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        isNew=0;
        
    end

end
end