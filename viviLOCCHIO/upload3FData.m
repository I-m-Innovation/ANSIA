function Data=upload3FData(app)

FERRO=Read3FFerroData(app);

status=evaluateData(FERRO);

error="";

if status=="NOLINK"
    error="Sezione Ferro in no link";
end

PLASTICA=Read3FPlasticaData(app);
status=evaluateData(PLASTICA);

if status=="NOLINK"

    if error=="Sezione Ferro in no link"
        error="Impianto in No Link!";

    else
        error="Sezione Plastica in no link";
    end
end

if isempty(error)==0

    printError(app,error);

end

Data.eta_FERRO=FERRO.ACPowers(end)/FERRO.DCPowers(end);
Data.eta_PLASTICA=PLASTICA.ACPowers(end)/PLASTICA.DCPowers(end);

Data.timeStamp=FERRO.TimeString;
try
    
    NFerro=length(FERRO.DCPowers);
    NPlastica=length(PLASTICA.DCPowers);
    N=min(NFerro,NPlastica);
    Data.PowerDC=FERRO.DCPowers(1:N)+PLASTICA.DCPowers(1:N);


catch err

    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con il calcolo DC di 3F",TEXT{:});

end

try

    NFerro=length(FERRO.ACPowers);
    NPlastica=length(PLASTICA.ACPowers);
    N=min(NFerro,NPlastica);
    Data.PowerAC=FERRO.ACPowers(1:N)+PLASTICA.ACPowers(1:N);

catch
    Recipients="stefano.trevisan@zilioservice.com";
    TEXT=string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con il calcolo AC di 3F",TEXT{:});

end