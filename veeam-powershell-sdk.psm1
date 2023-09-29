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
    
    $apiUrl = "https://$($Endpoint):$($Port)/api/oauth2/token"



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
            Write-Host "Successfully authenticated."
            $VBRAuthentication = [PSCustomObject]@{
                Session_endpoint       = $Endpoint
                Session_port           = $Port
                Session_access_token  = $response.access_token
            }
        
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

function Get-Jobs {
    <#
    .SYNOPSIS
        Uses Get-BackupJobs to retrive the backup jobs coordinated by the backup server/ 
    .DESCRIPTION
        This allows you to get an array of all jobs coordinated by the backup server.
    .OUTPUTS
        Returns the all jobs.
    .EXAMPLE
        

    #>
    
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$true)]
        [PSCustomObject]$VBRConnection,

        [Parameter(Position=0,mandatory=$false)]
        [String]$JobID
    )

     
    if ($JobID -eq $null){
        $apiUrl = "https://$($VBRConnection.Session_endpoint):$($VBRConnection.Session_post)/v1/jobs"
    } else {
        $apiUrl = "https://$($VBRConnection.Session_endpoint):$($VBRConnection.Session_post)/v1/jobs/" + $JobID
    }

    # Define the headers for the API request
    $headers = @{
        "x-api-version" = "1.1-rev0"
        "Authorization" = "Bearer $($VBRConnection.Session_access_token)"
    }

    # Send a request to get a list of backup jobs
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method GET -SkipCertificateCheck
        
        # Process the response data as needed
        return $response.data
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        return $null
    }
}


function Get-Backups {
    <#
    .SYNOPSIS
        Uses Get-Backups to retrive the backup  by the backup server.
    .DESCRIPTION
        This allows you to get a list of all the backups coordinated by the backup server.
    .OUTPUTS
        Returns the all backups.
    .EXAMPLE
        

    #>
    
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$true)]
        [PSCustomObject]$VBRConnection,

        [Parameter(Position=0,mandatory=$false)]
        [String]$BackupID
    )

     
    if ($BackupID -eq $null){
        $apiUrl = "https://$($VBRConnection.Session_endpoint):$($VBRConnection.Session_post)/v1/backups"
    } else {
        $apiUrl = "https://$($VBRConnection.Session_endpoint):$($VBRConnection.Session_post)/v1/backups/" + $BackupID
    }

    # Define the headers for the API request
    $headers = @{
        "x-api-version" = "1.1-rev0"
        "Authorization" = "Bearer $($VBRConnection.Session_access_token)"
    }

    # Send a request to get a list of backup jobs
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method GET -SkipCertificateCheck
        
        # Process the response data as needed
        return $response.data
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        return $null
    }
}



