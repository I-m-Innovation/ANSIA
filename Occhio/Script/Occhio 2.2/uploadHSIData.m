function Data=uploadHSIData(app)

id=53;
dev_id='2360PGKGI8E8';
logs_id='1999813';
potAttId='1999813104';
potProdId='1999813105';
potImmId='1999813106';
potAutoConsId='1999813107';

options1 = jsonencode(struct('username', 'Zilio group', 'password','he9gieLi'));
opt=weboptions('Timeout',30);
[FROM, TO]=DaysExtremes();

auth=webwrite('https://hsi.higeco.com/api/v1/authenticate',options1,opt);
authToken=weboptions('KeyName','authorization','KeyValue',auth.token,'ContentType','json','Timeout',30);

powerAtt=webread("https://hsi.higeco.com/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+potAttId+"?from="+FROM+"&to="+TO,authToken);
powerProd=webread("https://hsi.higeco.com/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+potProdId+"?from="+FROM+"&to="+TO,authToken);
powerImm=webread("https://hsi.higeco.com/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+potImmId+"?from="+FROM+"&to="+TO,authToken);
powerAutoCons=webread("https://hsi.higeco.com/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+potAutoConsId+"?from="+FROM+"&to="+TO,authToken);

try

    Data.powProdTime=datetime(powerProd.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.powProdValue=powerProd.data(:,2);

catch

    index=1;

    for i=1:length(powerProd.data)

        Test=powerProd.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.powProdTime(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'InputFormat', 'dd/MM/yyyy HH:mm:ss');

            Data.powProdValue(index,1)=Test(2);

        end

    end

    index=1;
end

try

    Data.powAttTime=datetime(powerAtt.data(:,1), 'convertfrom', 'posixtime', 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
    Data.powAttValue=powerAtt.data(:,2);

catch

    index=1;

    for i=1:length(powerAtt.data)

        Test=powerAtt.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.powAttTime(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');

            Data.powAttValue(index,1)=Test(2);

        end

    end

    index=1;
end
%%

try

    Data.powImmTime=datetime(powerImm.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.powImmValue=powerImm.data(:,2);

catch

    index=1;

    for i=1:length(powerImm.data)

        Test=powerImm.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.powImmTime(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');

            Data.powImmValue(index,1)=Test(2);

        end

    end

    index=1;
end

%%

try

    Data.powAutoConsTime=datetime(powerAutoCons.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.powAutoCons=powerAutoCons.data(:,2);

catch

    index=1;

    for i=1:length(powerAutoCons.data)

        Test=powerAutoCons.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.powAutoConsTime(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');

            Data.powAutoConsValue(index,1)=Test(2);

        end

    end

    index=1;
end
Data.Fault=0;

end