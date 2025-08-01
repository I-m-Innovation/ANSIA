function plotIdro(app,Data,Name)

app.CurrData=Data;
app.CurrName=Name;
Recipients="monitoraggio@zilioenvironment.com";

try

    cla(app.Graph);

end

Time=Data.timeStamp;
Q=Data.Flow;
P=Data.Power;
%Producibile=Data.Producibile;
Producibile =[];

PMean=mean(P)*ones(length(P),1);
QMean=mean(Q)*ones(length(Q),1);

if Name=="Partitore"

    QConc=25*ones(length(Q),1);
   % Pr=Data.Pressure;

elseif Name=="Ponte Giurino"

    QConc=80*ones(length(Q),1);
    %Pr=Data.Pressure;

elseif Name=="San Teodoro"

    QConc=70*ones(length(Q),1);
    %Pr=Data.Pressure;

elseif Name=="Torrino Foresta"

    QConc=1.54*ones(length(Q),1);
  %  Pr=Data.Pressure;

elseif Name=="SA3"

    QConc=1.80*ones(length(Q),1);
  %  Pr=Data.Pressure;
else
    QConc=[];
end

Producibile=[];
PlotH2OPower(app,Time,P,PMean,Producibile,Name);

try
PlotH2OCharge(app,Time,Q,QMean,QConc,Name);
catch err
%         isNew=identifyError(err,"PlotH2OCharge");
% 
%         if isNew==1
% 
%             TEXT="Errore in 'PlotH2OCharge("+Name+")'"+newline+string(err.message);
% %             sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
%             isNew=0;
%             
%         end 
end

if isempty(QConc)==0

    plotQMean(app,Q,Time,Data.MeanFlow2022);

% else
% 
%     legend(app.Graph,{'Potenza media oraria','Potenza media giornaliera','Portata media oraria','Portata media giornaliera'},'location','best','Orientation','vertical', ...
%     'FontSize',10);

end

setXAxisLimits(app);

hold(app.Graph,'off');

end