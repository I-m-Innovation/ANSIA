function Data=uploadPlantsData(app)

%%  SA3
try
    Data.SA3=ReadSA3Data();
catch err
    err.message
end

%%  Torrino Foresta
try
    Data.TorrinoForesta=ReadTorrinoForestaData();
catch err
    err.message
end

%%  PONTE GIURINO
try
    Data.PonteGiurino=ReadPonteGiurinoData2(app);
catch err
    err.message
end

%%  PARTITORE

try
    Data.Partitore=ReadPartitoreData();
catch err
    err.message
end

%%  SAN TEODORO

try
    Data.SanTeodoro=ReadSanTeodoroData();
catch err
    err.message;
end

% %%  RUBINO
% 
% try
%     Data.Rubino=ReadRubinoData();
% catch err
%     err.message
% end

% %%  SCN
% 
% try
%     Data.SCN=ReadSCNData();
% catch err
%     err.message;
% end
end