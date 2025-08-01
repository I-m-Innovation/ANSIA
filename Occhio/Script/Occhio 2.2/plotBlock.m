function plotBlock(app,Data)
    
times=length(Data(:,1));

t0=datetime('today',"InputFormat","dd/MM/uuuu HH:mm:ss","Format","dd/MM/uuuu HH:mm");
t0=t0+minutes(30);
tArray=t0:hours(1):(t0+hours(times-1));
bar(app.Graph,tArray,Data,'stacked','BarWidth',1,'FaceAlpha',0.8);
setXAxisLimits(app);
legend(app.Graph,{'San Teodoro','Partitore'});
ylabel(app.Graph,"Energia prodotta [kWh]");
app.Graph.FontSize=15;

end