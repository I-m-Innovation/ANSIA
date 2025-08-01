function SCN=uploadSCN_all(id,dev_id,logs_id,power_id,irradiation_id,FROM,TO,authToken)

power_id='1042242001';

power=webread("https://higeco-monitoraggio.it/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+power_id+"?from="+FROM+"&to="+TO,authToken);

try


    Data.timeStamp=datetime(power.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.Power=power.data(:,2);

catch

    index=1;

    for i=1:length(power.data)

        Test=power.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.timeStamp(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');

            Data.Power(index,1)=Test(2);

        end

    end

    index=1;
end



try

    SCN.Power=Data.Power;
    SCN.timeStamp=Data.timeStamp;
    SCN.Fault=0;

catch
    SCN.Fault=1;
end


end