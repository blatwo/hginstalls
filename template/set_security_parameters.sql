SELECT set_secure_param('hg_macontrol','min');
SELECT set_secure_param('hg_rowsecure','off');
SELECT set_secure_param('hg_showlogininfo','off');
SELECT set_secure_param('hg_clientnoinput','0');
SELECT set_secure_param('hg_idcheck.pwdpolicy','@PASSWORD_POLICY@');

