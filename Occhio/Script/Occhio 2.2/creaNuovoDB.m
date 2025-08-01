function creaNuovoDB(app)

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
Files=mget(ftpobj,"dati/ponte_giurino/");

charFiles=char(Files);
FileName=string(charFiles(:,end-20:end));
opts = detectImportOptions("dati/ponte_giurino/provaDB2.csv");
oldFile=readtable("dati/ponte_giurino/provaDB2.csv");
oldFile=readtable("provaDB2.csv");
N=length(FileName);

cd(ftpobj,"dati/ponte_giurino/");
riga=0;


for i=1:N

    if FileName(i)~="urino\provaDB2.csv   " && FileName(i)~="urino\provaDB.csv    " && FileName(i)~="urino\PGDataPDF.csv  " && FileName(i)~="urino\PGDataHTML.csv " && FileName(i)~="urino\PGDailyPlot.csv" && FileName(i)~="urino\DBPG.csv       " && FileName(i)~="provaDB2.csv         " && FileName(i)~="DBPG.csv             " && FileName(i)~="PGDailyPlot.csv      " && FileName(i)~="PGDataHTML.csv       " && FileName(i)~="PGDataPDF.csv        " && FileName(i)~="PGDataPDF.csv        " && FileName(i)~="provaDB.csv          "

        

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

    writetable(newFile,'provaDB2.csv','WriteVariableNames',true);
    mput(ftpobj,'provaDB2.csv');

end