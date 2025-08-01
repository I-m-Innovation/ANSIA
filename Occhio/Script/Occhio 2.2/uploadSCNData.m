function Data=uploadSCNData(app)

id=1032;
dev_id='2589LJTGI818';
logs_id='1042242';
power_id='1042242001';
irradiation_id='1042242009';

options1 = jsonencode(struct('username', 'ziliogroup', 'password','Yeeph4ue'));
opt=weboptions('Timeout',60);

[FROM, TO]=DaysExtremes();

auth=webwrite('https://higeco-monitoraggio.it/api/v1/authenticate',options1,opt);
authToken=weboptions('KeyName','authorization','KeyValue',auth.token,'ContentType','json','Timeout',30);

SCN=uploadSCN_all(id,dev_id,logs_id,power_id,irradiation_id,FROM,TO,authToken);
SCN.NoLinkIntervals=findNoLink(app,SCN,"SCN");

SCN1=uploadSCN1(id,dev_id,logs_id,power_id,irradiation_id,FROM,TO,authToken);
SCN1.NoLinkIntervals=findNoLink(app,SCN1,"SCN1");

SCN2=uploadSCN2(id,dev_id,logs_id,power_id,irradiation_id,FROM,TO,authToken);
SCN2.NoLinkIntervals=findNoLink(app,SCN2,"SCN2");

try
    irradiation=webread("https://higeco-monitoraggio.it/api/v1/getLogData/"+id+"/"+dev_id+"/"+logs_id+"/"+irradiation_id+"?from="+FROM+"&to="+TO,authToken);
end
try

    Data.irrTime=datetime(irradiation.data(:,1), 'convertfrom', 'posixtime', 'Format', 'dd/MM/yyyy HH:mm:ss');
    Data.irrValue=irradiation.data(:,2);

catch
    try
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

end


Data.P1=SCN1.P1;
Data.T1=SCN1.T1;
Data.P2=SCN2.P2;
Data.T2=SCN2.T2;
Data.TTot=SCN.timeStamp;
Data.PTot=SCN.Power;
Data.FermiTot=SCN.NoLinkIntervals;
Data.Fermi1=SCN1.NoLinkIntervals;
Data.Fermi2=SCN2.NoLinkIntervals;


end