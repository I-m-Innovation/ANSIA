function DATETIME=tStampConverter(time)

            for k=1:length(time)
            t=time{k};

            Anno=t(1,1:4);
            Mese=t(1,5:6);
            Giorno=t(1,7:8);
            Ora=t(1,9:10);
            Minuto=t(1,11:12);
            Secondo=t(1,13:14);

            tString=Giorno+"/"+Mese+"/"+Anno+" "+Ora+":"+Minuto+":"+Secondo;
            DATETIME(k,1)=datetime(tString,"InputFormat","dd/MM/uuuu HH:mm:ss","Format","dd/MM/uuuu HH:mm:ss");

        end

end