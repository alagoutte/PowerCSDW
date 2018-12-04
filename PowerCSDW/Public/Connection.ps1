#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-Csdw {

  <#
      .SYNOPSIS
      Connect to a Citrix SD WAN

      .DESCRIPTION
      Connect to a Citrix SD WAN
      .EXAMPLE
      Connect-Csdw -Server 192.0.2.1

      Connect to a Cotrix SD WAN with IP 192.0.2.1
  #>

    Param(
        [Parameter(Mandatory = $true, position=1)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credentials
    )

    Begin {
    }

    Process {

        $connection = @{server="";session=""}

        #If there is a password (and a user), create a credentials
        if ($Password) {
            $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
        }
        #Not Credentials (and no password)
        if ($Credentials -eq $null)
        {
            $Credentials = Get-Credential -Message 'Please enter administrative credentials for your Citrix SD WAN'
        }

        #Allow untrusted SSL certificat and enable TLS 1.2 (needed by Citrix SD WAN)
        Set-CsdwUntrustedSSL
        Set-CsdwCipherSSL

        $postParams = @{ login = @{username=$Credentials.username;password=$Credentials.GetNetworkCredential().Password}}
        $url = "https://${Server}/sdwan/nitro/v1/config/login"
        $headers = @{ "Content-type" = "application/json" }

        try {
            $response = Invoke-WebRequest $url -Method POST -Body ($postParams | ConvertTo-Json) -headers $headers -SessionVariable csdw
        }
        catch {
            Show-CdswException $_
            throw "Unable to connect to Citrix SD WAN"
        }

        $connection.server = $server
        $connection.session = $csdw

        set-variable -name DefaultCsdwConnection -value $connection -scope Global

        $response
    }

    End {
    }
}