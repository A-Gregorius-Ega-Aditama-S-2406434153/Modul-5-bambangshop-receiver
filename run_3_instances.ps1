$MainAppPath = "D:\rustrover\babang-shop\bambangshop"
$ReceiverAppPath = "D:\rustrover\babang-shop\bambangshop-receiver"


function Start-RustInstance {
    param(
        [string]$Title,
        [string]$Path,
        [string]$Port,
        [string]$InstanceName,
        [string]$PublisherUrl = "http://localhost:8000",
        [bool]$IsReceiver = $true
    )

    if ($IsReceiver) {
        $cmd = @"
`$env:ROCKET_PORT="$Port"
`$env:APP_INSTANCE_ROOT_URL="http://localhost:$Port"
`$env:APP_PUBLISHER_ROOT_URL="$PublisherUrl"
`$env:APP_INSTANCE_NAME="$InstanceName"
cd "$Path"
cargo run
"@
    }
    else {
        $cmd = @"
cd "$Path"
cargo run
"@
    }

    Start-Process powershell -ArgumentList @(
        "-NoExit",
        "-Command",
        $cmd
    ) -WindowStyle Normal
}

Write-Host "Starting Main App on port 8000..."
Start-RustInstance -Title "Main App" -Path $MainAppPath -Port "8000" -InstanceName "Main" -IsReceiver $false

Start-Sleep -Seconds 2

Write-Host "Starting Receiver 1 on port 8001..."
Start-RustInstance -Title "Receiver 1" -Path $ReceiverAppPath -Port "8001" -InstanceName "Receiver 1"

Write-Host "Starting Receiver 2 on port 8002..."
Start-RustInstance -Title "Receiver 2" -Path $ReceiverAppPath -Port "8002" -InstanceName "Receiver 2"

Write-Host "Starting Receiver 3 on port 8003..."
Start-RustInstance -Title "Receiver 3" -Path $ReceiverAppPath -Port "8003" -InstanceName "Receiver 3"

Write-Host ""
Write-Host "All instances launched."
Write-Host "Main app:       http://localhost:8000"
Write-Host "Receiver 1:     http://localhost:8001"
Write-Host "Receiver 2:     http://localhost:8002"
Write-Host "Receiver 3:     http://localhost:8003"