function Data=ReadHonda2Data1(app)


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
ps_id='5086460';
ps_list=["5086064_1_6_1";"5086064_1_5_1";"5086064_1_4_1";"5086064_1_3_1";"5086064_1_2_1";"5086064_1_1_1";"5086064_5_7_1"];

%% Configurazione istanti di lettura
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

    % quali inverter stanno funzionando?
    % Se funzionano tutti -> 

    try
        invOn=string(fieldnames(responseDC.Body.Data.result_data));
        Ninv=length(fieldnames(responseDC.Body.Data.result_data));
    end

    for j=1:Ninv %ciclo sul numero di inverter funzionanti
        cfrList="x"+ps_list;
        indInv=find(cfrList==invOn(j));
        try
            tempo=string({responseDC.Body.Data.result_data.(invOn(j)).time_stamp}'); %estraggo i dati di tempo

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

            try
                 PowerTestDC(:,indInv)=double(string({responseDC.Body.Data.result_data.(invOn(j)).p14}')); % estraggo la potenza in DC

            catch err
                try
                    DimLHS = length(PowerTestDC);
                    DimRHS = length(double(string({responseDC.Body.Data.result_data.(invOn(j)).p14}')));

                    if string(err.message) ~= "Unable to perform assignment because the size of the left side is "+DimLHS+"-by-1 and the size of the right side is "+DimRHS+"-by-1."
                        Recipients="stefano.trevisan@zilioservice.com";
                        TEXT="Errore in 'ReadHonda1Data'"+newline+string(err.message);
                        %                 sendmail2(Recipients,"viviL'OCCHIO: problema con PowerTestDC, riga 66",TEXT{:});
                    end
                end
            end
            try
                PowerTestAC(:,indInv)=double(string({responseAC.Body.Data.result_data.(invOn(j)).p24}')); % estraggp la potenza in AC
            end
        end

        if t0==start %inizio

            try

                PDC=sum(PowerTestDC,2);

            catch err
                PDC=nan*ones(37,1);

                Recipients="stefano.trevisan@zilioservice.com";
                TEXT="problema con il PowerTestDC a riga 82."+newline+"Start a:"+string(start);
                %     sendmail2(Recipients,"viviL'OCCHIO:"+string(err.message),TEXT{:});

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
            try
                PDC=[PDC;sum(PowerTestDC(2:end,:),2)];
                PAC=[PAC;sum(PowerTestAC(2:end,:),2)];
                T_Plant=[T_Plant;Time(2:end)];
            end
        end

        try
        clear Time
        end

        try
            clear PowerTestDC;
        end
        try
        clear PowerTestAC;
        end


    end

    start=start+hours(3);
    stop=stop+hours(3);
end



Data.TimeString=T_Plant+hours(1);
Data.DCPowers=PDC/1000;
Data.ACPowers=PAC/1000;

