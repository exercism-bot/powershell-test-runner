$arg1 = $args[0]
$arg2 = $args[1]
$arg3 = $args[2]
$arg4 = $args[3]

$PesterConfig = New-PesterConfiguration
$PesterConfig.TestResult.OutputFormat = "NUnitXml"
$PesterConfig.TestResult.OutputPath = $arg1
$PesterConfig.TestResult.Enabled = $True
$PesterConfig.Run.Path = $arg3 
$PesterConfig.Should.ErrorAction = 'Continue'

cd $arg2

Invoke-Pester -Configuration $PesterConfig 

$testlist = [System.Collections.ArrayList]::new()

Select-Xml -Path $arg1 -XPath "//test-case" | ForEach-Object {
    $test = [ordered]@{ 
        name = $_.Node.description
        status = "success"
    }
    if ($_.Node.result -eq "Failure"){
        $test.status = "fail"
        $test.message = "Message: " + $_.Node.failure.message + "`n`nStack-trace: " + $_.Node.failure.'stack-trace'
    }

    $testlist.Add($test)
}

$test = [ordered]@{
    version = 2
    status = "succes"
    tests = $testlist
}

if ($testlist | Where-Object { $_.status -eq "fail" }) {
    $test.status = "fail"
}

$test | ConvertTo-Json  | Out-File -FilePath $arg4
