#! /snap/bin/pwsh
cd /home/ubuntu/labPkiPy

mkdir "/etc/nginx"
$baseP = "/etc/nginx/pki"
mkdir $baseP
$artifacts = $baseP + "/artifacts/"
mkdir $artifacts

$baseHTTP = "http://pki.fflab.markgamache.com/"


#consider for future.  Crereate root and ICA that are not part of the Gamache FF Trust Root 2018 hierarcy. Issue a cert from it.  X-sign that cert with Gamache FF Trust Root 2018 and update the chain to send the x-sign cert
    # update py code to support KU and then have some fun there.
    # don't set BCs at all
    # ski and aki https://cryptography.io/en/latest/x509/reference/#cryptography.x509.AuthorityKeyIdentifier.from_issuer_public_key
    # add a CA and cert whtere CDP is listed but not there.
    # add a CA wehre the CRL is signed by some other key



# Gamache FF Trust Root 2018
    $did = & python3 ./DoCAStuff.py --mode NewRootCA --basepath $baseP --name "Gamache FF Trust Root 2018" --validfrom janOf2018 --validto janOf2048 --keysize 4096 --pathlength 2 # --ncallowed "fflab.markgamache.com,mtlspkilab.markgamache.com"
    $certBack = $did | ConvertFrom-Json
    $rootCert = $certBack

    #AIA
    "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt" -Encoding ascii -NoNewline
    Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"
    Copy-Item -Force  "$($certBack.basePath)/cert.pem" "$($artifacts)/_LabRoot.crt"


    #crl
    "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
    "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt" -Encoding ascii -NoNewline
    $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Trust Root 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear 
    $crlBack = $did | ConvertFrom-Json
    Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"


    # Gamache FF Int CA 1 
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Int CA 1" --signer "Gamache FF Trust Root 2018" --validfrom janOf2018 --validto janOf2028 --keysize 2048 --pathlength 0
        $certBack = $did | ConvertFrom-Json
        $intCA = $certBack

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt" -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl  
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt" -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Int CA 1" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"
 

    # Gamache FF Super ICA 1 
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Super ICA 1" --signer "Gamache FF Int CA 1" --validfrom janOf2018 --validto janOf2028 --keysize 2048 --pathlength 0
        $certBack = $did | ConvertFrom-Json
        $intCA = $certBack

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt" -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl  
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt" -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Int CA 1" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"


        # tapman.fflab.markgamache.com .  
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "tapman.fflab.markgamache.com" --signer "Gamache FF Super ICA 1" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
            $did | ConvertFrom-Json



    # Gamache FF Int CA 1776 
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Int CA 1776" --signer "Gamache FF Trust Root 2018" --validfrom dtMinusTenMin --validto janOf2028 --keysize 2048 --pathlength 1 --hash SHA1
        $certBack = $did | ConvertFrom-Json
        $intCA = $certBack

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt" -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl  
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt" -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Int CA 1776" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"
        

        # Gamache FF Issuer 1776
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Issuer 1776" --signer "Gamache FF Int CA 1776" --validfrom dtMinusTenMin --validto janOf2028 --keysize 2048 --pathlength 0
        $certBack = $did | ConvertFrom-Json
        $intCA = $certBack

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt" -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl  
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt" -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Issuer 1776" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"



            # whittlebury.fflab.markgamache.com .  
                $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "whittlebury.fflab.markgamache.com" --signer "Gamache FF Issuer 1776" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
                #$did | ConvertFrom-Json
                #send with no chain
                $certBack = $did | ConvertFrom-Json
                $certBack 
                Remove-Item "$($certBack.basePath)/certwithchain.pem"
                cp "$($certBack.basePath)/cert.pem" "$($certBack.basePath)/certwithchain.pem" 


    # Gamache FF Int CA 2018 
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Int CA 2018" --signer "Gamache FF Trust Root 2018" --validfrom janOf2018 --validto janOf2028 --keysize 2048 --pathlength 1
        $certBack = $did | ConvertFrom-Json
        $intCA = $certBack

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt" -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl  
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt" -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Int CA 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"
        $longInt = "$($certBack.basePath)/cert.pem"


    # Gamache FF Some Assurance ICA 2018  old
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Some Assurance ICA 2018" --signer "Gamache FF Int CA 2018" --validfrom janOf2018 --validto marchOf2018 --keysize 2048 --pathlength 0
        $certBack = $did | ConvertFrom-Json

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt"  -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt"  -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Some Assurance ICA 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"

    

        #revoke this cert
        $certBack.serial| Out-File -FilePath "$($intCA.basePath)/revoked.txt"  -Encoding ascii -Append
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Int CA 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($intCA.serial).crl"



            # Suggs.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "suggs.fflab.markgamache.com" --signer "Gamache FF Some Assurance ICA 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
            $did | ConvertFrom-Json

        #get rid of the old CA cert
        ren "$($certBack.basePath)/cert.pem" "$($certBack.basePath)/certold.rem"
        $oldSAICACert = "$($certBack.basePath)/certold.rem"


        
    
    # Gamache FF Some Assurance ICA 2019  new
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Some Assurance ICA 2019" --signer "Gamache FF Int CA 2018" --validfrom marchOf2018 --validto dtPlusFiveYears --keysize 2048 --pathlength 0
        $certBack = $did | ConvertFrom-Json

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt"  -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"
        

        #crl
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt"  -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Some Assurance ICA 2019" --validfrom marchOf2018 --validto dtMinusTenMin 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"


            # Nick-Nack.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "Nick-Nack.fflab.markgamache.com" --signer "Gamache FF Some Assurance ICA 2019" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
            $certBack = $did | ConvertFrom-Json
            $certBack 
            
    
    
    # Gamache FF Some Assurance ICA 2018  new
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Some Assurance ICA 2018" --signer "Gamache FF Int CA 2018" --validfrom marchOf2018 --validto dtPlusFiveYears --keysize 2048 --pathlength 0
        $certBack = $did | ConvertFrom-Json

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt"  -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"
        

        #crl
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt"  -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Some Assurance ICA 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"


        # Hollabackatcha.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "hollabackatcha.fflab.markgamache.com" --signer "Gamache FF Some Assurance ICA 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
            $certBack = $did | ConvertFrom-Json
            $certBack 
            Remove-Item "$($certBack.basePath)/certwithchain.pem"
            cp "$($certBack.basePath)/cert.pem" "$($certBack.basePath)/certwithchain.pem" 
            cat $oldSAICACert >> "$($certBack.basePath)/certwithchain.pem" 
            cat $longInt >> "$($certBack.basePath)/certwithchain.pem" 
    

    # Gamache FF Server ICA  
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Server ICA" --signer "Gamache FF Int CA 2018" --validfrom janOf2018 --validto dtPlusFiveYears --keysize 2048 --isca False
        $certBack = $did | ConvertFrom-Json

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt"  -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt"  -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Int CA 2018" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"


        # Francois.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "francois.fflab.markgamache.com" --signer "Gamache FF Server ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
            $did | ConvertFrom-Json



    # Gamache FF Server HA ICA  old and expired  create a new one with same key and new dates. issue one cert from this
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Server HA ICA" --signer "Gamache FF Int CA 2018" --validfrom janOf2018 --validto marchOf2018 --keysize 2048 --pathlength 0
        $certBack = $did | ConvertFrom-Json

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt"  -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt"  -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"

    

        # spellingbee.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "spellingbee.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
            $did | ConvertFrom-Json

            #get rid of the old CA cert
            ren "$($certBack.basePath)/cert.pem" "$($certBack.basePath)/certold.rem"
            $oldHACert = "$($certBack.basePath)/certold.rem"
            #Start-Sleep -Seconds 2



    # Gamache FF Server HA ICA  new
        $did = & python3 ./DoCAStuff.py --mode NewSubCA --basepath $baseP --name "Gamache FF Server HA ICA" --signer "Gamache FF Int CA 2018" --validfrom dtMinusTwoYears --validto dtPlusFiveYears --keysize 2048 --pathlength 0  #--ncallowed "newpkilab.markgamache.com,fflab.markgamache.com" --ncdisallowed "threat.fflab.markgamache.com"
        $certBack = $did | ConvertFrom-Json

        #AIA
        "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt"  -Encoding ascii -NoNewline
        Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

        #crl
        "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
        "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt"  -Encoding ascii -NoNewline
        $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear 
        $crlBack = $did | ConvertFrom-Json
        Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"

        #the big list of messups

             # disher.fflab.markgamache.com the cert should have CN, but no san  no small keys  =(
            #$did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "disher.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 1024 
            #$did | ConvertFrom-Json


            # banking.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "banking.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

            # gustice.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "gustice.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

             # RadioStar.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "RadioStar.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

             # Cheswicke.fflab.markgamache.com this site has no TLS issues. sabotaged by Public-Key-Pins.  Public-Key-Pins are no longer a thing!!!
            #$did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "Cheswicke.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            #$did | ConvertFrom-Json

            #bankofplace 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "www.bankofplace.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

             # burrito.fflab.markgamache.com the cert should have CN, but no san  SHA is banned  =(
            #$did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "burrito.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 --hash SHA1
            #$did | ConvertFrom-Json

            # marrion.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "marrion.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 --noekus
            $did | ConvertFrom-Json

            # magichead.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "magichead.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json
            #make the short chain 
            Remove-Item "$($baseP)/magichead.fflab.markgamache.com/certwithchain.pem"
            cp "$($baseP)/magichead.fflab.markgamache.com/cert.pem"  "$($baseP)/magichead.fflab.markgamache.com/certwithchain.pem"
            Get-Content "$($baseP)/Gamache FF Server HA ICA/cert.pem" | Out-File -Encoding ascii -FilePath "$($baseP)/magichead.fflab.markgamache.com/certwithchain.pem" -Append


            # soclose.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "soclose.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json
            #make the short chain 
            Remove-Item "$($baseP)/soclose.fflab.markgamache.com/certwithchain.pem"
            cp "$($baseP)/soclose.fflab.markgamache.com/cert.pem"  "$($baseP)/soclose.fflab.markgamache.com/certwithchain.pem"
            

             # yang.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "yang.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 --nosans
            $did | ConvertFrom-Json

             # notgreat.fflab.markgamache.com claims to be a CA
            #$did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "notgreat.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 --isca True
            #$did | ConvertFrom-Json

             #  threat.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "threat.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json


             #  TheBlackGoose.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafClient --basepath $baseP --name "TheBlackGoose.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

             #  reference.fflab.markgamache.com cert is good for reference
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "reference.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

             #  OvaltineJenkins.newpkilab.markgamache.com  
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "OvaltineJenkins.newpkilab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json


            #  mega.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "mega.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

             #  trading.fflab.markgamache.com 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "trading.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json

            #make big chain
            $labcerts = (dir ../FFPKILab/labcerts).FullName 
            foreach($c in $labcerts)
            {
                gc $c >> "$($baseP)/mega.fflab.markgamache.com/certwithchain.pem"
            }


            # 
            #  chad.fflab.markgamache.com the cert 
            $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "chad.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            $did | ConvertFrom-Json
            gc "$($baseP)/chad.fflab.markgamache.com/cert.pem" > "$($baseP)/chad.fflab.markgamache.com/certwithchain.pem"
            gc $oldHACert >> "$($baseP)/chad.fflab.markgamache.com/certwithchain.pem"
            gc $longInt >> "$($baseP)/chad.fflab.markgamache.com/certwithchain.pem"


            #lassie
            # lassie  client certr from CA that is not in list for banking or trading
            $did = & python3 ./DoCAStuff.py --mode NewLeafClient --basepath $baseP --name "lassie" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 --nosans
            $did | ConvertFrom-Json

            mkdir "/var/www/clientcerts.fflab.markgamache.com"
            Copy-Item "$($baseP)/lassie/certwithchain.pem" "/var/www/clientcerts.fflab.markgamache.com/lassie.pem" 
            Copy-Item "$($baseP)/lassie/key.pem" "/var/www/clientcerts.fflab.markgamache.com/lassie.key" 

            #chain wiht cert not first is a no good scenerio 
            #  racecar.fflab.markgamache.com the cert should have CN, but no san
            #$did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "racecar.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            #$did | ConvertFrom-Json
            #gc "$($baseP)/racecar.fflab.markgamache.com/cert.pem" > "$($baseP)/racecar.fflab.markgamache.com/certwithchain.pem"
            #gc $oldHACert > "$($baseP)/racecar.fflab.markgamache.com/certwithchain.pem"
            #gc $longInt >> "$($baseP)/racecar.fflab.markgamache.com/certwithchain.pem"
            #gc "$($baseP)/racecar.fflab.markgamache.com/cert.pem" >> "$($baseP)/racecar.fflab.markgamache.com/certwithchain.pem"

            #hopefully tls 1 and fails in some browser.  NGINX can only pick one choice for tls version  =(
             #  slicks.fflab.markgamache.com cert is good for reference
            #$did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "slicks.fflab.markgamache.com" --signer "Gamache FF Server HA ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 
            #$did | ConvertFrom-Json

           

#Gamache Client ICA
    $did = & python3 ./DoCAStuff.py --mode NewSubCaClientAuth --basepath $baseP --name "Gamache Client ICA" --signer "Gamache FF Int CA 2018" --validfrom dtMinusTenMin --validto dtPlusFiveYears --keysize 2048 --pathlength 0
    $certBack = $did | ConvertFrom-Json

    #AIA
    "$($baseHTTP)$($certBack.serial).crt" | Out-File -FilePath "$($certBack.basePath)/aia.txt"  -Encoding ascii -NoNewline
    Copy-Item -Force  "$($certBack.DERFile)" "$($artifacts)/$($certBack.serial).crt"

    #crl
    "badf00d" | Out-File -FilePath "$($certBack.basePath)/revoked.txt"  -Encoding ascii
    "$($baseHTTP)$($certBack.serial).crl" | Out-File -FilePath "$($certBack.basePath)/cdp.txt"  -Encoding ascii -NoNewline
    $did = & python3 ./DoCAStuff.py --mode SignCRL --basepath $baseP --signer "Gamache Client ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear 
    $crlBack = $did | ConvertFrom-Json
    Copy-Item -Force $crlBack.basePath "$($artifacts)/$($certBack.serial).crl"


    # 
        # arsassin.fflab.markgamache.com  
        $did = & python3 ./DoCAStuff.py --mode NewLeafTLS --basepath $baseP --name "arsassin.fflab.markgamache.com" --signer "Gamache Client ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048
        $did | ConvertFrom-Json

    #thesealion
        # thesealion  client certr from client CA
        $did = & python3 ./DoCAStuff.py --mode NewLeafClient --basepath $baseP --name "thesealion" --signer "Gamache Client ICA" --validfrom dtMinusTenMin --validto dtPlusOneYear --keysize 2048 --nosans
        $did | ConvertFrom-Json

        
        Copy-Item "$($baseP)/thesealion/certwithchain.pem" "/var/www/clientcerts.fflab.markgamache.com/thesealion.pem" 
        Copy-Item "$($baseP)/thesealion/key.pem" "/var/www/clientcerts.fflab.markgamache.com/thesealion.key" 

#perms on the keys

& chmod -R 777 /etc/nginx/pki/*

#& aws s3 sync /etc/nginx/pki/ s3://certsync/pki

