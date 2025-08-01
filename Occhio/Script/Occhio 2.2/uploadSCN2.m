function Data=uploadSCN2(id,dev_id,logs_id,power_id,irradiation_id,FROM,TO,authToken)

    power_id='1042242121';
    power=webread("https://higeco-monitoraggio.it/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+power_id+"?from="+FROM+"&to="+TO,authToken);

    try


    Data.T2=datetime(power.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.P2=power.data(:,2);
    Data.Fault=0;

catch
try
    index=1;

    for i=1:length(power.data)
        
        Test=power.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.T2(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');

            Data.P2(index,1)=Test(2);

        end

    end

    index=1;
    if exist('Data','var')
    Data.Fault=0;
    else
        Data.Fault=1;
    end
catch
    Data.Fault=1;
    end
end

end