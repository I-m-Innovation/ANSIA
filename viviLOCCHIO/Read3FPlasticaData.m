function Data=Read3FPlasticaData(app)


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
ps_id='5079150';
ps_list=["5079150_1_9_1";"5079150_1_5_1";"5079150_1_1_1";
    "5079150_1_8_1";"5079150_1_4_1";"5079150_1_7_1";"5079150_1_3_1";"5079150_1_6_1"];

start=datetime("today","Format","dd/MM/uuuu HH:mm:ss");
t0=start;
stop=start+hours(3);
try
    while start<=datetime('Now')

        tOFF=string(year(stop))+num2str(month(stop),'%02.f')+num2str(day(stop),'%02.f')+num2str(hour(stop),'%02.f')+num2str(minute(stop),'%02.f')+num2str(floor(second(stop)),'%02.f');
        tON=string(year(start))+num2str(month(start),'%02.f')+num2str(day(start),'%02.f')+num2str(hour(start),'%02.f')+num2str(minute(start),'%02.f')+num2str(floor(second(start)),'%02.f');
        dataDC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'points','p14','start_time_stamp',tON,'end_time_stamp',tOFF);
        uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
        body = matlab.net.http.MessageBody(dataDC);
        request = matlab.net.http.RequestMessage(method,header,body);
        [responseDC,completedrequest,history] = send(request,uri);

        dataAC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'points','p24','start_time_stamp',tON,'end_time_stamp',tOFF);
        uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
        body = matlab.net.http.MessageBody(dataAC);
        request = matlab.net.http.RequestMessage(method,header,body);
        [responseAC,completedrequest,history] = send(request,uri);

        Ninv=length(fieldnames(responseAC.Body.Data.result_data));


        for j=1:Ninv

            tempo=string({responseDC.Body.Data.result_data.("x"+ps_list(j)).time_stamp}');

            for k=1:length(tempo)
                t=tempo{k};

                Anno=t(1,1:4);
                Mese=t(1,5:6);
                Giorno=t(1,7:8);
                Ora=t(1,9:10);
                Minuto=t(1,11:12);
                Secondo=t(1,13:14);

                tString=Giorno+"/"+Mese+"/"+Anno+" "+Ora+":"+Minuto+":"+Secondo;
                Time(k,1)=datetime(tString,"InputFormat","dd/MM/uuuu HH:mm:ss","Format","dd/MM/uuuu HH:mm:ss");

            end

            PowerTestDC(:,j)=double(string({responseDC.Body.Data.result_data.("x"+ps_list(j)).p14}'));
            PowerTestAC(:,j)=double(string({responseAC.Body.Data.result_data.("x"+ps_list(j)).p24}'));

        end

        if t0==start

            PDC=sum(PowerTestDC,2);
            PAC=sum(PowerTestAC,2);
            T_Plant=Time;

        else

            PDC=[PDC;sum(PowerTestDC(2:end,:),2)];
            PAC=[PAC;sum(PowerTestAC(2:end,:),2)];

            T_Plant=[T_Plant;Time(2:end)];

        end

        clear PowerTestDC
        clear PowerTestAC
        clear Time
        start=start+hours(3);
        stop=stop+hours(3);

    end

catch

    PDC=nan;
    PAC=nan;

    data3=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list);
    uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getPVInverterRealTimeData');
    body = matlab.net.http.MessageBody(data3);
    request = matlab.net.http.RequestMessage(method,header,body);
    [response,completedrequest,history] = send(request,uri);

    TempoGrezzo=response.Body.Data.result_data.device_point_list(1).device_point.device_time;
    Anno=TempoGrezzo(1:4);
    Mese=TempoGrezzo(5:6);
    Giorno=TempoGrezzo(7:8);
    Ora=TempoGrezzo(9:10);
    Minuto=TempoGrezzo(11:12);
    Secondo=TempoGrezzo(13:14);
    T_Plant=Giorno+"/"+Mese+"/"+Anno+" "+Ora+":"+Minuto+":"+Secondo;

end

    Data.TimeString=T_Plant;
    Data.DCPowers=PDC/1000;
    Data.ACPowers=PAC/1000;

