function Data = readDatiSolari(app)

firstRad=0;
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
ps_listSolar=["5086064_5_7_1";"5086064_5_7_1"];

start=datetime("today","Format","dd/MM/uuuu HH:mm:ss")-hours(1);
t0=start;
stop=start+hours(3);

while start<=datetime('Now')

tOFF=string(year(stop))+num2str(month(stop),'%02.f')+num2str(day(stop),'%02.f')+num2str(hour(stop),'%02.f')+num2str(minute(stop),'%02.f')+num2str(floor(second(stop)),'%02.f');
tON=string(year(start))+num2str(month(start),'%02.f')+num2str(day(start),'%02.f')+num2str(hour(start),'%02.f')+num2str(minute(start),'%02.f')+num2str(floor(second(start)),'%02.f');
dataSolar=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',ps_listSolar,'points','p2019','start_time_stamp',tON,'end_time_stamp',tOFF);
uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
body = matlab.net.http.MessageBody(dataSolar);
requestSolar = matlab.net.http.RequestMessage(method,header,body);
[responseSolar,completedrequest,history] = send(requestSolar,uri);

Irrag=responseSolar.Body.Data.result_data;

if length(fieldnames(Irrag))>0

    if firstRad==0

        SolarTime=tStampConverter(string({Irrag.x5086064_5_7_1.time_stamp}));
        SolarValue=double(string({Irrag.x5086064_5_7_1.p2019}))';
        firstRad=1;

    else

        SolarTime=[SolarTime;tStampConverter(string({Irrag.x5086064_5_7_1.time_stamp}))];
        SolarValue=[SolarValue;double(string({Irrag.x5086064_5_7_1.p2019}))'];
        firstRad=1;

    end

end
    start=start+hours(3);
    stop=stop+hours(3);
end


Data.SolarMeterTime=SolarTime;
Data.SolarMeterIrrad=SolarValue;
end