clc
clear all
close all

%% Script di test dell'API sungrow di HONDA

% login
data=struct('appkey','AAA324AF620903ED6ECCDDEA0B6BC866','user_account','tecnico@zilioservice.com','user_password','monitorinG_eesco22','lang','_it_IT');

uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/login');
method = matlab.net.http.RequestMethod.POST;
header = matlab.net.http.HeaderField('x-access-key', 'dpiixeb8cnn34widwp7ihg5nzfb8eybw', 'sys_code',  '901',...
    'Content-Type','application/json');

body = matlab.net.http.MessageBody(data);
request = matlab.net.http.RequestMessage(method,header,body);
[response,completedrequest,history] = send(request,uri);

authTok=response.Body.Data.result_data.token;

%% Lista impianti

data=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','curPage','1','size','5');
uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getPowerStationList');
body = matlab.net.http.MessageBody(data);
request = matlab.net.http.RequestMessage(method,header,body);
[PlantList,completedrequest,history] = send(request,uri);



HONDA1='5086460';
HONDA2='5086064';
HONDATETTO='5086074';

%%  DEVICES HONDA 1

data=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_id',HONDA1,'curPage','1','size','10');
uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDeviceList');
body = matlab.net.http.MessageBody(data);
request = matlab.net.http.RequestMessage(method,header,body);
[H1Dev,completedrequest,history] = send(request,uri);

PS_KEY=["5086460_1_4_1";"5086460_1_3_1";"5086460_1_2_1";"5086460_1_1_1";"5086460_9_247_1"];

%% REAL TIME HONDA 1

data=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',PS_KEY);
uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getPVInverterRealTimeData');
body = matlab.net.http.MessageBody(data);
request = matlab.net.http.RequestMessage(method,header,body);
[PowerTest,completedrequest,history] = send(request,uri);

%%  time data HONDA 1

start=datetime("today","Format","dd/MM/uuuu HH:mm:ss")+hours(12);
t0=start;
stop=start+hours(3);
tOFF=string(year(stop))+num2str(month(stop),'%02.f')+num2str(day(stop),'%02.f')+num2str(hour(stop),'%02.f')+num2str(minute(stop),'%02.f')+num2str(floor(second(stop)),'%02.f');
tON=string(year(start))+num2str(month(start),'%02.f')+num2str(day(start),'%02.f')+num2str(hour(start),'%02.f')+num2str(minute(start),'%02.f')+num2str(floor(second(start)),'%02.f');
dataDC=struct('token',authTok,'appkey','AAA324AF620903ED6ECCDDEA0B6BC866','ps_key_list',PS_KEY,'points','p14','start_time_stamp',tON,'end_time_stamp',tOFF);
uri=matlab.net.URI('https://gateway.isolarcloud.eu/openapi/getDevicePointMinuteDataList');
body = matlab.net.http.MessageBody(dataDC);
request = matlab.net.http.RequestMessage(method,header,body);

[responseDC,completedrequest,history] = send(request,uri);


