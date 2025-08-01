function Data = RefreshData(app,Plant)

try
    app.FirstStart = 0;
    switchStateLamp(app,Plant);

    try
        delete(app.errLabel);
    end

    if Plant == "San Teodoro"
        Type= "hydro";

        try
            Data = processST(app,Plant);
        end

    elseif Plant=="Condotta San Teodoro"

        Type="hydro";

        try

            Data = processPP(app,Plant);


        end

    elseif Plant == "Partitore"

        Type= "hydro";

        try
            Data = processPartitore(app,Plant);
        catch err
            err.message()
        end

    elseif Plant == "Ponte Giurino"
        Type= "hydro";

        try
            Data = processPG(app,Plant);
        end

    elseif Plant == "Torrino Foresta"
        Type= "hydro";

        try
            Data = processTF(app,Plant);
        end

    elseif Plant == "SCN - Pilota"
        Type= "PV";

        try
            Data=processSCN(app,Plant);
        end

    elseif Plant=="Rubino"
        Type= "PV";

        try
            Data=processRubino(app,Plant);
        end



    elseif Plant=="Zilio Group 20 kW"
        Type= "HSI";

        try

            Data=processDI(app,Plant);
        end

        elseif Plant=="SA3"
        Type= "hydro";

        try

            Data=processSA3(app,Plant);
        end

    end

    try
        evaluateStatus(app,Data,Plant);
    end

    try
        EffLab(app,Data,Type,Plant);
    end

    try
        TimeLab(app);
    end

    try
        app.CurrData=Data;
        app.CurrPlant=Plant;
    end

catch err
    sendmail2("monitoraggio@zilioenvironment.com","L'OCCHIO: problema in RefreshData",err.message)
end


end