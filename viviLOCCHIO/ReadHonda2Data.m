function Data=ReadHonda2Data(app)
firstRad=0;
PAC = [];
%% PREPARAZIONE CALL

data=struct('appkey','AAA324AF620903ED6ECCDDEA0B6BC866','user_account','tecnico@zilioservice.com','user_password','monitorinG_eesco22','lang','_it_IT');


uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/login');
method = matlab.net.http.RequestMethod.POST;
header = matlab.net.http.HeaderField('x-access-key', 'dpiixeb8cnn34widwp7ihg5nzfb8eybw', 'sys_code',  '901',...
    'Content-Type','application/json');

body = matlab.net.http.MessageBody(data);
request = matlab.net.http.RequestMessage(method,header,body);
[response,completedrequest,history] = send(request,uri);

try
    authTok=response.Body.Data.result_data.token;
catch err

    Recipients="stefano.trevisan@zilioservice.com";
    TEXT="Errore in 'ReadHonda2Data'"+newline+string(err.message);
%     sendmail2(Recipients,"viviL'OCCHIO: problema con result_data.token, riga 24",TEXT{:});

end

ps_id='5086064';
ps_list=["5086064_1_6_1";"5086064_1_5_1";"5086064_1_4_1";"5086064_1_3_1";"5086064_1_2_1";"5086064_1_1_1";"5086064_5_7_1"];

start=datetime("today","Format","dd/MM/uuuu HH:mm:ss")-hours(1);
t0=start;
stop=start+hours(3);
firstRad=0;

while start<=datetime('Now')

    tOFF=string(year(stop))+num2str(month(stop),'%02.f')+num2str(day(stop),'%02.f')+num2str(hour(stop),'%02.f')+num2str(minute(stop),'%02.f')+num2str(floor(second(stop)),'%02.f');
    tON=string(year(start))+num2str(month(start),'%02.f')+num2str(day(start),'%02.f')+num2str(hour(start),'%02.f')+num2str(minute(start),'%02.f')+num2str(floor(second(start)),'%02.f');
    dataDC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'points','p14','start_time_stamp',tON,'end_time_stamp',tOFF);
    dataAC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'points','p24','start_time_stamp',tON,'end_time_stamp',tOFF);

%     uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getPVInverterRealTimeData');

    uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
    body = matlab.net.http.MessageBody(dataDC);
    requestDC = matlab.net.http.RequestMessage(method,header,body);
    [responseDC,completedrequest,history] = send(requestDC,uri);

    body = matlab.net.http.MessageBody(dataAC);
    requestAC = matlab.net.http.RequestMessage(method,header,body);
    [responseAC,completedrequest,history] = send(requestAC,uri);
    ps_listSolar=["5086064_5_7_1";"5086064_5_7_1"];

    point_list=['2007';'2009'];
    %     dataSolar=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'device_type','5','point_id_list',point_list,'start_time_stamp',tON,'end_time_stamp',tOFF);
    %     uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDeviceRealTimeData');

    dataSolar=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_listSolar,'points','p2019','start_time_stamp',tON,'end_time_stamp',tOFF);
    uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
    body = matlab.net.http.MessageBody(dataSolar);
    requestSolar = matlab.net.http.RequestMessage(method,header,body);
    [responseSolar,completedrequest,history] = send(requestSolar,uri);

    try
        invOn=string(fieldnames(responseDC.Body.Data.result_data));
        Ninv=length(fieldnames(responseDC.Body.Data.result_data));

    catch err

        CampiInOutput=string(fieldnames(responseDC.Body.Data.result_data));
        Recipients="stefano.trevisan@zilioservice.com";
        TEXT="Errore in 'ReadHonda2Data'"+newline+string(err.message);
%         sendmail2(Recipients,"viviL'OCCHIO: problema con result_data, riga 63",TEXT{:},"HONDA2ResponseDC.txt");

    end

    for j=1:Ninv

        try
            tempo=string({responseDC.Body.Data.result_data.(invOn(j)).time_stamp}');
        catch err
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="Errore in 'ReadHonda2Data'"+newline+string(err.message);
%             sendmail2(Recipients,"viviL'OCCHIO: problema con result_data, riga 60",TEXT{:});
        end

        Time=tStampConverter(tempo);
        
        if j==1
            NSample=length(Time);
        end

        try
            preTestDC=double(string({responseDC.Body.Data.result_data.(invOn(j)).p14}'));

            try
                PowerTestDC(:,j)=preTestDC(1:NSample,:);
            catch
                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="PowerTestDC a riga 98"; 
%                 sendmail2(Recipients,"viviL'OCCHIO: Errore in ReadHonda2Data",TEXT{:});                
            end

        end

        try

            PowerTestAC(1:NSample,j)=double(string({responseAC.Body.Data.result_data.(invOn(j)).p24}'));

        catch err
            
            DimLHS = length(PowerTestAC);
            DimRHS = length(double(string({responseAC.Body.Data.result_data.("x"+ps_list(j)).p24}')));

            if string(err.message) ~= "Unable to perform assignment because the size of the left side is "+DimLHS+"-by-1 and the size of the right side is "+DimRHS+"-by-1.";
                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'ReadHonda2Data'"+newline+string(err.message);
%                 sendmail2(Recipients,"viviL'OCCHIO: problema con PowerTestAC, riga 108",TEXT{:});
            end


        end
    end
    Irrag=responseSolar.Body.Data.result_data;

    if length(fieldnames(Irrag))>0

        if firstRad==0

            SolarTime=tStampConverter(string({Irrag.x5086064_5_7_1.time_stamp}));
            SolarValue=double(string({Irrag.x5086064_5_7_1.p2019}))';
            firstRad=1;

        else

            SolarTime=[SolarTime;tStampConverter(string({Irrag.x5086064_5_7_1.time_stamp}))];
            SolarValue=[SolarValue;double(string({Irrag.x5086064_5_7_1.p2019}))'];

        end

    end

    if t0==start
        try
            PDC=sum(PowerTestDC,2);
        catch
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="PowerTestDC a riga 138"; 
%             sendmail2(Recipients,"viviL'OCCHIO: Errore in ReadHonda2Data",TEXT{:});    
        end

         PAC=sum(PowerTestAC,2);
        T_Plant=Time+hours(1);

    else
        try

            PDC=[PDC;sum(PowerTestDC(2:end,:),2)];

        catch
            tStart = T_Plant(end);
            Recipients="stefano.trevisan@zilioservice.com";
            TEXT="PowerTestDC a riga 151 al tStart="+string(tStart); 
%             sendmail2(Recipients,"viviL'OCCHIO: Errore in ReadHonda2Data",TEXT{:});

        end

        try
            PAC=[PAC;sum(PowerTestAC(2:end,:),2)];
        catch err
            err
        end
    try
        T_Plant=[T_Plant;Time(2:end)];
    catch err
        err
    end
    end
    try
        clear PowerTestDC
    catch
        Recipients="stefano.trevisan@zilioservice.com";
        TEXT="PowerTestDC a riga 164"; 
%         sendmail2(Recipients,"viviL'OCCHIO: Errore in ReadHonda2Data",TEXT{:});
    end
    clear PowerTestAC
    clear Time;

    start=start+hours(3);
    stop=stop+hours(3);

end

Data.SolarMeterTime=SolarTime;
Data.SolarMeterIrrad=SolarValue;
Data.TimeString=T_Plant+hours(1);
Data.DCPowers=PDC/1000;
Data.ACPowers=PAC/1000;

