function creaNuovoDBTF(app)

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
Files=mget(ftpobj,"dati/Torrino_Foresta/");

charFiles=char(Files);
FileName=string(charFiles(:,end-20:end));
oldFile=readtable("dati/Torrino_Foresta/DBTF.csv");
% OldDB=readtable("DBTF.csv");
N=length(FileName);

cd(ftpobj,"dati/Torrino_Foresta/");
riga=0;


for i=1:N

    if FileName(i)~="DBTF.csv             " && FileName(i)~="rino_Foresta\DBTF.csv"
        

        File=mget(ftpobj,FileName(i));
        opts = detectImportOptions(string(File));

        opts=setvaropts(opts,"x__TimeStamp","InputFormat","dd/MM/uuuu HH:mm:ss");


        File=readtable(string(File),opts);
        riga=riga+1;
%        toAppend{riga,:}=File;
        newFile = [oldFile;File];
        oldFile = newFile;

        delete(ftpobj,FileName(i));
        delete(FileName(i));
          
        
    end
end

try

    writetable(newFile,'DBTF.csv','WriteVariableNames',true);
    mput(ftpobj,'DBTF.csv');

end


