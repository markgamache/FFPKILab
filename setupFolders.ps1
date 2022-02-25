﻿#! /snap/bin/pwsh
$names = (dir -Directory /etc/nginx/pki | where Name -like "*.*").name 


foreach($n in $names)
{
    #New-Item -ItemType Directory -Path "/var/www/" -Name $($n) -ErrorAction SilentlyContinue
    #New-Item -ItemType Directory -Path "/etc/nginx/pki/" -Name $($n) -ErrorAction SilentlyContinue

$html = @"
<!DOCTYPE html>
<html>
<head>
<title>Welcome to the Lab</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to the Lab</h1>
<p>If you see this page, you have reached the web server on $($n).</p>

</body>
</html>


"@ 
#Write-Host $html

    $html |  Out-File -FilePath "/var/www/$($n)/index.html"  -Force -Encoding ascii

}


#cps folder probalby empty but needed for nginx to statrt
mkdir "/var/www/cps.fflab.markgamache.com"

#folder for client certs and keys will allow dir listing
mkdir "/var/www/clientcerts.fflab.markgamache.com"

#instructions
mkdir "/var/www/instructions.fflab.markgamache.com"


$instHTML = @"
<!DOCTYPE html>
<html>
<head>
<title>Welcome to the Lab</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to the Lab</h1>
<h2>These are the URLs of pain. Diagnose them please</h2>
<br><br>
reference.fflab.markgamache.com should be working 100% and is meant to test your tools
<br><br>
<a href=`"http://pki.fflab.markgamache.com/_LabRoot.crt`" target=`"_blank`" rel=`"noopener noreferrer`">Lab Root Cert. Be careful. It is scary insecure</a><br><br>
<a href=`"http://clientcerts.fflab.markgamache.com`" target=`"_blank`" rel=`"noopener noreferrer`" >Client Certs and Keys can be found here</a>
<br><br>
"@


foreach($n in $names)
{
    $instHTML += "<a href=`"http://$($n)`" target=`"_blank`" rel=`"noopener noreferrer`" >$($n)</a>"
    $instHTML += "<br>"

}

$instHTML += @'
</body>
</html>
'@

 $instHTML | Out-File -Encoding ascii -FilePath "/var/www/instructions.fflab.markgamache.com/index.html"

& chmod -R 777 /var/www/*
