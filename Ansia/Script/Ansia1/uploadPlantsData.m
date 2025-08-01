function Data=uploadPlantsData(app)
%%  PONTE GIURINO
try

    Data.PonteGiurino=ReadPonteGiurinoData(app);

catch err

    Obj='WARNING PONTE GIURINO FROM ANSIA';
    errReport(app,err,Obj);

end

%%  PARTITORE

try

    Data.Partitore=ReadPartitoreData();

catch err

    Obj='WARNING PARTITORE FROM ANSIA';
    errReport(app,err,Obj);

end

%%  SAN TEODORO

try

    Data.SanTeodoro = ReadSanTeodoroData();

catch err

    Obj='WARNING SAN TEODORO FROM ANSIA';
    errReport(app,err,Obj);

end

%%  RUBINO

try

    Data.Rubino = ReadRubinoData();

catch err

    Obj='WARNING RUBINO FROM ANSIA';
    errReport(app,err,Obj);

end

%%  SCN

try

    Data.SCN=ReadSCNData();

catch err

    Obj='WARNING SCN FROM ANSIA';
    errReport(app,err);

end

end