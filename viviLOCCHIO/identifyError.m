function isNew=identifyError(err,FuncName)

isNew=0;
host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
Files=mget(ftpobj,"dati/Database_Produzione");

List=readtable("dati/Database_Produzione/ErrorList3.csv");
cd(ftpobj,"dati/Database_Produzione");


if FuncName=="processST"

    ErrTag="ST";

elseif FuncName=="processPartitore"

    ErrTag="PAR";

elseif FuncName=="refreshEffLabel"

    ErrTag='EFFLAB';

elseif FuncName=="processPG"

    ErrTag='PG';

elseif FuncName=="processSCN"

        ErrTag='SCN';

elseif FuncName=="processRubino"

    ErrTag='Rub';

elseif FuncName=="processDI"

    ErrTag='DI';
elseif FuncName=="refreshTimeLabel"
    ErrTag='TIMELAB';
elseif FuncName=="RefreshData"
    ErrTag='REFDATA';    
end


try

    Sigla=List.SiglaErrore(string(List.Messaggio)==string(err.message) & string(List.SiglaErrore)==string(ErrTag));
    Numero=List.NumeroErrore(string(List.Messaggio)==string(err.message));
    Num=Numero(end);

catch
    try
        List.SiglaErrore{end+1}=ErrTag;
        List.NumeroErrore(end)=string(1 + max(List.NumeroErrore(string(List.SiglaErrore)==ErrTag)));
        Num=string(List.NumeroErrore{end});
    catch
        Num=string(1);
        List.Funzione{end}=FuncName{:};
        List.Messaggio{end}=err.message;
       List.NumeroErrore(end)=Num{:};
       isNew=1;

    end

    writetable(List,"ErrorList3.csv");
    mput(ftpobj,'ErrorList3.csv');

end

ErrorLog=readtable("dati/Database_Produzione/ErrorLog.csv");

ErrorLog.TimeStamp(end+1)=string(datetime('now','Format',"dd/MM/uuuu HH:mm:ss"));
Tag=string(ErrTag)+string(Num);
ErrorLog.Codice{end}=Tag{:};
try
    Occorrenze=max(ErrorLog.Occorrenze(ErrorLog.Codice==ErrTag+string(Num)));
    ErrorLog.Occorrenze(end)=Occorrenze+1;
catch
    ErrorLog.Occorenze(end)=1;
end

writetable(ErrorLog,"ErrorLog.csv");
mput(ftpobj,'ErrorLog.csv');

end