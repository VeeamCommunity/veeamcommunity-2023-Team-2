$ErrorActionPreference = 'Stop'
function New-VBRConnection {
    <#
    .SYNOPSIS
        Uses New-VBRConnection to store the connection in a global parameter
    .DESCRIPTION
        Creates a Veeam Server connection and stores it in global variable $Global:DefaultVeeamBR. 
        An FQDN or IP, credentials, and ignore certificate boolean
    .OUTPUTS
        Returns the Veeam Server connection.
    .EXAMPLE
        

    #>

    [CmdletBinding()]
    Param(
  
        [Parameter(Position=0,mandatory=$true)]
        [string]$Endpoint,

        [Parameter(Position=1,mandatory=$true)]
        [string]$Port, 

        [Parameter(Position=2,mandatory=$true)]
        [string]$User, 

        [Parameter(Position=3,mandatory=$true)]
        [string]$Pass 

    )
    
    $apiUrl = "https://'$Endpoint':'$Port'/api/oauth2/token"



    # Define the headers for the API request
    $headers = @{
        "Content-Type"  = "application/x-www-form-urlencoded"
        "x-api-version" = "1.1-rev0"
    }

    ## TO-DO: Grant_type options
    $body = @{
        "grant_type" = "password"
        "username"   = $User
        "password"   = $Pass
    }

    # Send an authentication request to obtain a session token
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Post -Body $body -SkipCertificateCheck 
        
        if (($response.access_token) -or ($response.StatusCode -eq 200) ) {
            $VBRAuthentication = @{
                $session_endpoint       = $Endpoint
                $session_port           = $Port
                $session_access_tocken  = $response.access_token
            }
            Write-Host "Successfully authenticated."
            return $VBRAuthentication 
        }
        else {
            Write-Host "Authentication failed. Status code: $($response.StatusCode), Message: $($response.Content)"
        }
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
    }
}

function Get-BackupJobs {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$true)]
        [VeeamServer.Authentication]$VBRAuthentication
    )

    VBRAuthentication
    $apiUrl = "https://'$($VBRAuthentication.$session_endpoint)':'$($VBRAuthentication.$session_post)'/v1/jobs?skip=0&limit=0&orderColumn=Name&orderAsc=true&nameFilter=string&typeFilter=Backup"
    
    # Define the headers for the API request
    $headers = @{
        "x-api-version" = "1.1-rev0"
        "Authorization" = "Bearer '$($VBRAccessToken.$session_access_tocken)'"
    }


    Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method GET -SkipCertificateCheck
}
