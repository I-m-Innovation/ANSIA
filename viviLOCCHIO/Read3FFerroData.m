function Data=Read3FFerroData(app)


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
ps_id='5079244';
ps_list=["5079244_1_1_1";"5079244_1_2_1";"5079244_1_3_1"];

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
        requestDC = matlab.net.http.RequestMessage(method,header,body);
        [responseDC,completedrequest,history] = send(requestDC,uri);

        dataAC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list,'points','p24','start_time_stamp',tON,'end_time_stamp',tOFF);
        uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
        body = matlab.net.http.MessageBody(dataAC);
        requestAC = matlab.net.http.RequestMessage(method,header,body);
        [responseAC,completedrequest,history] = send(requestAC,uri);

        Ninv=length(fieldnames(responseDC.Body.Data.result_data));

        try
            invOn=string(fieldnames(responseDC.Body.Data.result_data));
            Ninv=length(fieldnames(responseDC.Body.Data.result_data));
        end

        for j=1:Ninv
            cfrList="x"+ps_list;
            indInv=find(cfrList==invOn(j));
        try
            tempo=string({responseDC.Body.Data.result_data.(invOn(j)).time_stamp}'); %estraggo i dati di tempo

            for k=1:length(tempo)
                if k== 37
                    A=2
                end
                    
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
    end

        if t0==start

        try
            PDC=sum(PowerTestDC,2);
        catch
                PDC=nan*ones(37,1);
        end

        try
            PAC=sum(PowerTestAC,2);
        catch
            PAC=nan*ones(37,1);

        end
        try
            T_Plant=Time;
        catch
            T_Plant=start:minutes(5):stop
        end

        else

            PDC=[PDC;sum(PowerTestDC(2:end,:),2)];
            PAC=[PAC;sum(PowerTestAC(2:end,:),2)];

            T_Plant=[T_Plant;Time(2:end)];

        end

        try
            clear PowerTestDC
        end
        try
            clear PowerTestAC
        end
        try
            clear Time
        end
        start=start+hours(3);
        stop=stop+hours(3);


    end

catch err
    
%     err
%     PDC=nan;
%     PAC=nan;
% 
%     data3=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_list);
%     uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getPVInverterRealTimeData');
%     body = matlab.net.http.MessageBody(data3);
%     request = matlab.net.http.RequestMessage(method,header,body);
%     [response,completedrequest,history] = send(request,uri);
% 
%     TempoGrezzo=response.Body.Data.result_data.device_point_list(1).device_point.device_time;
%     Anno=TempoGrezzo(1:4);
%     Mese=TempoGrezzo(5:6);
%     Giorno=TempoGrezzo(7:8);
%     Ora=TempoGrezzo(9:10);
%     Minuto=TempoGrezzo(11:12);
%     Secondo=TempoGrezzo(13:14);
%     T_Plant=Giorno+"/"+Mese+"/"+Anno+" "+Ora+":"+Minuto+":"+Secondo;

end

Data.TimeString=T_Plant;
Data.DCPowers=PDC/1000;
Data.ACPowers=PAC/1000;



