function [FROM, TO] = DaysExtremes()
Today=datetime("now","Format","dd/MM/yyyy hh:mm");

if month(Today)>9

    FROM=posixtime(datetime(day(Today)+"/"+month(Today)+"/"+year(Today)+" 00:00",'InputFormat','dd/MM/uuuu HH:mm'));

else

    FROM=posixtime(datetime(day(Today)+"/0"+month(Today)+"/"+year(Today)+" 00:00","InputFormat","dd/MM/uuuu HH:mm"));

end

TO=round(posixtime(datetime("now")));%-3600;

end