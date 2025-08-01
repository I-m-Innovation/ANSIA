function Data=ReadHonda3Data(app)

firstRad=0;
%% PREPARAZIONE CALL

data=struct('appkey','AAA324AF620903ED6ECCDDEA0B6BC866','user_account','tecnico@zilioservice.com','user_password','monitorinG_eesco22','lang','_it_IT');


uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/login');
method = matlab.net.http.RequestMethod.POST;
header = matlab.net.http.HeaderField('x-access-key', 'dpiixeb8cnn34widwp7ihg5nzfb8eybw', 'sys_code',  '901',...
    'Content-Type','application/json');

body = matlab.net.http.MessageBody(data);
request = matlab.net.http.RequestMessage(method,header,body);
[response,completedrequest,history] = send(request,uri);

authTok=response.Body.Data.result_data.token;

ps_id='5086074';
ps_list=["5086074_1_3_1";"5086074_1_2_1"];


start=datetime("today","Format","dd/MM/uuuu HH:mm:ss")-hours(1);
t0=start;
stop=start+hours(3);

while start<=datetime('Now')

    tOFF=string(year(stop))+num2str(month(stop),'%02.f')+num2str(day(stop),'%02.f')+num2str(hour(stop),'%02.f')+num2str(minute(stop),'%02.f')+num2str(floor(second(stop)),'%02.f');
    tON=string(year(start))+num2str(month(start),'%02.f')+num2str(day(start),'%02.f')+num2str(hour(start),'%02.f')+num2str(minute(start),'%02.f')+num2str(floor(second(start)),'%02.f');
    dataDC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'points','p14','start_time_stamp',tON,'end_time_stamp',tOFF);
    dataAC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'points','p24','start_time_stamp',tON,'end_time_stamp',tOFF);
    uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
    body = matlab.net.http.MessageBody(dataDC);
    request = matlab.net.http.RequestMessage(method,header,body);
    [responseDC,completedrequest,history] = send(request,uri);

    body = matlab.net.http.MessageBody(dataAC);
    request = matlab.net.http.RequestMessage(method,header,body);
    [responseAC,completedrequest,history] = send(request,uri);

    ps_listSolar=["5086074_5_1_1";"5086074_5_1_1"];

    dataSolar=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_listSolar,'points','p2019','start_time_stamp',tON,'end_time_stamp',tOFF);
    uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
    body = matlab.net.http.MessageBody(dataSolar);
    requestSolar = matlab.net.http.RequestMessage(method,header,body);
    [responseSolar,completedrequest,history] = send(requestSolar,uri);

%     Ninv=length(fieldnames(responseDC.Body.Data.result_data));

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
            B=2;
        end
        Time=tStampConverter(tempo);

        if j==1

            NSample=length(Time);

        end


        try

            preTestDC=double(string({responseDC.Body.Data.result_data.(invOn(j)).p14}'));
            try

                PowerTestDC(:,j)=preTestDC(1:NSample,:);

            catch err

                if string(err.message)~="Reference to a cleared variable PowerTestDC."
                    Recipients="stefano.trevisan@zilioservice.com";
                    TEXT="Errore in 'ReadHonda3Data'"+newline+string(err.message);
                    %                 sendmail2(Recipients,"viviL'OCCHIO: problema con result_data, riga 61",TEXT{:});
                end

            end


        end

        try
            PowerTestAC(1:NSample,j)=double(string({responseAC.Body.Data.result_data.(invOn(j)).p24}'));
        catch err
            if string(err.message)~="Reference to a cleared variable PowerTestAC."
                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="Errore in 'ReadHonda3Data'"+newline+string(err.message);
                %                 sendmail2(Recipients,"viviL'OCCHIO: problema con result_data, riga 74",TEXT{:});
            end
        end
    end

    Irrag=responseSolar.Body.Data.result_data;

    if length(fieldnames(Irrag))>0

        if firstRad==0

            SolarTime=tStampConverter(string({Irrag.x5086074_5_1_1.time_stamp}));
            SolarValue=double(string({Irrag.x5086074_5_1_1.p2019}))';
            firstRad=1;
        else

            SolarTime=[SolarTime;tStampConverter(string({Irrag.x5086074_5_1_1.time_stamp}))];
            SolarValue=[SolarValue;double(string({Irrag.x5086074_5_1_1.p2019}))'];

        end
    end

    if t0==start
        try
        PDC=sum(PowerTestDC,2);
        end
        PAC=sum(PowerTestAC,2);
        T_Plant=Time+hours(1);
    else
        try
            PDC=[PDC;sum(PowerTestDC(2:end,:),2)];
        catch
                        tStart = T_Plant(end);
        end

try
            PAC=[PAC;sum(PowerTestAC(2:end,:),2)];
end
try
            T_Plant=[T_Plant;Time(2:end)];

        catch err

            B=2;
        end
    end
try
    clear PowerTestDC;
end
    clear PowerTestAC;
    clear Time;

    start=start+hours(3);
    stop=stop+hours(3);

end

Data.SolarMeterTime=SolarTime+hours(1);
Data.SolarMeterIrrad=SolarValue;
Data.TimeString=T_Plant+hours(1);
Data.DCPowers=PDC/1000;
Data.ACPowers=PAC/1000;

end