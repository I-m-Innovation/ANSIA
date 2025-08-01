function ReadData(app)

try

    if datetime("now")>=datetime('05:30:00','Format','HH:mm:ss') && datetime('now')<=datetime('23:59:59','Format','HH:mm:ss')


        readAndSend(app);

    else

        setEmailOptions(app);
        Text='';
        Obj='ANSIA riposa serenamente';
        sendmail2('stefano.trevisan@zilioenvironment.com',Obj,Text);

    end

catch err
    
    Obj = "DEBUG ANSIA";
    errReport(app,err,Obj);

end

