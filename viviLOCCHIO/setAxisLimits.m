function setAxisLimits(app,h)

Today=datetime("now",InputFormat="dd/MM/yyyy hh:mm");
START=datetime(day(Today)+"/"+month(Today)+"/"+year(Today)+" 00:00:00", 'Format','dd/MM/uuuu HH:mm:ss');
STOP=datetime(day(Today)+"/"+month(Today)+"/"+year(Today)+" 23:59:00", 'Format','dd/MM/uuuu HH:mm:ss');

xlim(app.Graph,[START STOP]);
ylim(app.Graph,[0 h]);

end