function Data=uploadHondaData(app)

try
     HONDA1=ReadHonda1Data(app); % estrae le grandezze
catch err
    Recipients="stefano.trevisan@zilioservice.com";
    TEXT="Errore in 'ReadHonda1Data()'"+newline+string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con la lettura di HONDA1",TEXT{:});
end

try
    HONDA2=ReadHonda2Data1(app);
catch err
    Recipients="stefano.trevisan@zilioservice.com";
    TEXT="Errore in 'ReadHonda2Data()'"+newline+string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con la lettura di HONDA2",TEXT{:});
end

try
    DatiSolari = readDatiSolari(app);
end

try
    HONDA3=ReadHonda3Data(app);
catch err
    Recipients="stefano.trevisan@zilioservice.com";
    TEXT="Errore in 'ReadHonda3Data()'"+newline+string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con la lettura di HONDA3",TEXT{:});
end

try

    Data.eta_HONDA1=HONDA1.ACPowers(end)/HONDA1.DCPowers(end);

catch err

    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con rendimento di HONDA1",TEXT{:});

end

try

Data.eta_HONDA2=HONDA2.ACPowers(end)/HONDA2.DCPowers(end);

catch err

    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con rendimento di HONDA2",TEXT{:});

end

try
Data.eta_HONDA3=HONDA3.ACPowers(end)/HONDA3.DCPowers(end);
catch err

    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con rendimento di HONDA2",TEXT{:});

end
vect=[HONDA1.TimeString;HONDA2.TimeString;HONDA3.TimeString]
Data.timeStamp=unique(vect);
try

N1=length(HONDA1.DCPowers);
N2=length(HONDA2.DCPowers);
N3=length(HONDA3.DCPowers);

N=min([N1,N2,N3]);
Data.PowerDC=HONDA1.DCPowers(1:N)+HONDA2.DCPowers(1:N)+HONDA3.DCPowers(1:N);
catch err
    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con il calcolo DC di Honda",TEXT{:});
end

try
N1=length(HONDA1.ACPowers);
N2=length(HONDA2.ACPowers);
N3=length(HONDA3.ACPowers);
TimeIrrGates=HONDA2.SolarMeterTime;
ValIrrGates=HONDA2.SolarMeterIrrad;

TimeIrrRoof=HONDA3.SolarMeterTime;
ValIrrRoof=HONDA3.SolarMeterIrrad;

NSoleGates=length(ValIrrGates);
NSoleRoof=length(ValIrrRoof);
NSole=min([NSoleGates,NSoleRoof]);

ITot=((492.48+354.24)*ValIrrGates(1:NSole)+142.56*ValIrrRoof(1:NSole))/(492.48+354.24+142.56);
Data.SolarTime=TimeIrrRoof;
Data.SolarValue=ITot;
IGates=1;
IRoof=1;
N=min([N1,N2,N3]);
Data.PowerAC=HONDA1.ACPowers(1:N)+HONDA2.ACPowers(1:N)+HONDA3.ACPowers(1:N);
catch err

    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message)+newline+...
        "N1 = "+length(HONDA1.ACPowers)+newline+...
        "N2 = "+length(HONDA2.ACPowers)+newline+...
        "N3 = "+length(HONDA3.ACPowers)+newline;
%     sendmail2(Recipients,"viviL'OCCHIO: problema con il calcolo AC di Honda",TEXT{:}); 

    try

    catch err2
    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con il salvataggio AC di Honda",TEXT{:});    
end

end