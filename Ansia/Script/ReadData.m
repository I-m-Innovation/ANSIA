function ReadData(app)



    if datetime("now")>=datetime('05:30:00','Format','HH:mm:ss') && datetime('now')<=datetime('23:59:59','Format','HH:mm:ss')


            readAndSend(app);

    else

        setEmailOptions(app);
        Text='';
        Obj='ANSIA riposa serenamente';
        sendmail2('stefano.trevisan@zilioenvironment.com',Obj,Text);

    end
