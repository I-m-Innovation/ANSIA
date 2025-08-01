function DBCleaner(app)

host='192.168.10.211';
ftpobj=ftp(host,'ftpdaticentzilio','Sd2PqAS.We8zBK');
Files=mget(ftpobj,"dati/ponte_giurino/");

charFiles=char(Files);
FileName=string(charFiles(:,end-20:end));
oldFile=readtable("dati/ponte_giurino/DBPG.csv");

cd(ftpobj,"dati/ponte_giurino/");
N=length(FileName);
riga=0;
for i=1:N

    if FileName(i)~="DBPG.csv             " &&   FileName(i)~="onte_giurino\DBPG.csv" &&   FileName(i)~="DBPG.csv"
        

        File=mget(ftpobj,FileName(i));
        opts = detectImportOptions(string(File));

        opts=setvaropts(opts,"x__TimeStamp","InputFormat","dd/MM/uuuu HH:mm:ss");


        File=readtable(string(File),opts);
        riga=riga+1;
        toAppend(riga,:)=File;

          delete(ftpobj,FileName(i));
          delete(FileName(i));
          
        
    end
end
try
newFile=[oldFile;toAppend];
writetable(newFile,'DBPG.csv','WriteVariableNames',true);
mput(ftpobj,'DBPG.csv');
end

end

        