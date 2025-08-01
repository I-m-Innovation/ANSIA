function [Recipients,  mailObj]=setEmailOptions()

% Recipients=["damiano.zilio@krunos.com","stefano.trevisan@zilioservice.com","trevisan.stefano.91@gmail.com","marco.spagnoli@zilioenvironment.com"];
Recipients=["stefano.trevisan@zilioenvironment.com"];%,"trevisan.stefano.91@gmail.com","damiano.zilio@zilioservice.com","marco.spagnoli@zilioenvironment.com"];

mailObj="L'ANSIA delle "+string(datetime('now','Format','HH:mm'));
setpref('Internet','E_mail','monitoraggio@zilioservice.com');
setpref('Internet','SMTP_Server','mail.webcloud.it');
setpref('Internet','SMTP_Username', 'monitoraggio@zilioservice.com');
setpref('Internet','SMTP_Password', 'Ct&8i16j2');
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty( 'mail.smtp.starttls.enable', 'true' );
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

end