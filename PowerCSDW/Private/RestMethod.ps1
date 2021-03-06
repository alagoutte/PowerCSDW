#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-CsdwRestMethod{

    Param(
        [Parameter(Mandatory = $true)]
        [String]$uri,
        [Parameter(Mandatory = $true)]
        [ValidateSet("GET", "PUT", "POST", "DELETE")]
        [String]$method,
        [Parameter(Mandatory = $false)]
        [psobject]$body
    )

    Begin {
    }

    Process {

        $Server = ${DefaultCsdwConnection}.Server
        $fullurl = "https://${Server}/${uri}"

        #When headers, We need to have Accept and Content-type set to application/json...
        $headers = @{ Accept = "application/json"; "Content-type" = "application/json" }

        $sessionvariable = $DefaultCsdwConnection.session

        try {
            if($body){
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers -WebSession $sessionvariable
            } else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers -WebSession $sessionvariable
            }
        }

        catch {
            Show-CdswException $_
            throw "Unable to use Citrix SDWAN NITRO API"
        }
        $response

    }

}