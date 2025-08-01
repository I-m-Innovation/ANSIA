function Data=uploadRubinoData(app)

id=992;
dev_id='3189OVTGIDEF';
logs_id='1042331';
power_id='1042331001';
irradiation_id='1042331009';
options1 = jsonencode(struct('username', 'ziliogroup', 'password','Yeeph4ue'));
opt=weboptions('Timeout',60);

Today=datetime("now",InputFormat="dd/MM/yyyy hh:mm");

if month(Today)>9
    Today_00=posixtime(datetime(day(Today)+"/"+month(Today)+"/"+year(Today)+" 00:00","InputFormat","dd/MM/uuuu HH:mm","Format","dd/MM/uuuu HH:mm"));
else
    Today_00=posixtime(datetime(day(Today)+"/0"+month(Today)+"/"+year(Today)+" 00:00","InputFormat","dd/MM/uuuu HH:mm","Format","dd/MM/uuuu HH:mm"));

end

auth=webwrite('https://higeco-monitoraggio.it/api/v1/authenticate',options1,opt);
%                 B=webwrite('https://higeco-monitoraggio.it/api/v1/authenticate',app.Data.PV.WebOptions);
authToken=weboptions('KeyName','authorization','KeyValue',auth.token,'ContentType','json','Timeout',30);


TO=round(posixtime(datetime("now")));%-3600;

power=webread("https://higeco-monitoraggio.it/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+power_id+"?from="+Today_00+"&to="+TO,authToken);

irradiation=webread("https://higeco-monitoraggio.it/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+irradiation_id+"?from="+Today_00+"&to="+TO,authToken);


try

    Data.irrTime=datetime(irradiation.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.irrValue=irradiation.data(:,2);

catch

    index=1;

    for i=1:length(irradiation.data)
        Test=irradiation.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.irrTime(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');

            Data.irrValue(index,1)=Test(2);

        end

    end

end

try


    Data.powTime=datetime(power.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.powValue=power.data(:,2);

catch

    index=1;

    for i=1:length(power.data)
        
        Test=power.data{i};

        if iscell(Test)==0
            index=index+1;
            Data.powTime(index,1)=datetime(Test(1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');

            Data.powValue(index,1)=Test(2);

        end

    end

    index=1;
end

Data.Fermi=findNoLink(app,Data,"Rubino");


end