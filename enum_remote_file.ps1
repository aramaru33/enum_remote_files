$output_directory_path = "C:\\Users\arase\Desktop\net_view"
$net_view_file_path = "$output_directory_path\netview.txt"
$log_file_path = "C:\\Users\arase\Desktop\net_view\netview.log"

$server = "192.168.11.51"
$user = "testuser"
$password = "p@ssw0rd~!"

# Start script
$script_file = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
echo "[$current_time] Script $script_file start. server:$server" >> $log_file_path

# Enumerate share
$current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
echo "[$current_time] Start enumerating share . server:$server" >> $log_file_path
net view \\$server /all > $net_view_file_path 2>>$log_file_path 

if($?) {
    $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    echo "[$current_time] Finish enumerating share successfuly. server:$server" >> $log_file_path
}
else {
    $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    echo "[$current_time] Error occurred while enumerating share. server:$server" >> $log_file_path
    exit
}

$net_view_lines = Get-Content $net_view_file_path
$shares = @()
foreach($line in $net_view_lines){
    $elements = $line.Trim() -split '\s+'
    if($elements[1] -eq "disk"){
        $shares += $elements[0]
    }
}

foreach($share in $shares){
    # Mount share
    $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    echo "[$current_time] Start mount share. server:$server share:$share" >> $log_file_path
    
    # If user is set
    if(($user -eq $null) -or ($password -eq $null)){
        echo "" | net use \\$server\$share /persistent:no >> $log_file_path 2>&1
    }
    # If user is not set
    else{
        net use \\$server\$share /user:$user $password /persistent:no >> $log_file_path 2>&1
    }

    if($?){
        $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
        echo "[$current_time] Finish mount share successfuly. server:$server share:$share" >> $log_file_path
    }
    # If user Don't have access right. 
    elseif($Error[3].toString().contains("1223")) {
        $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
        echo "[$current_time] Don't have right to access share. server:$server share:$share" >> $log_file_path
        continue
    }
    else{
        $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
        echo "[$current_time] Error occurred while mounting share. server:$server share:$share" >> $log_file_path
        exit
    }

    # Enumerate files
    $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    echo "[$current_time] File enumeration start. server:$server share:$share" >> $log_file_path
    cmd /c where /R \\$server\$share *.* > "$output_directory_path\files_$share" 2>>$null
    $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    echo "[$current_time] File enumeration finish. server:$server share:$share" >> $log_file_path

    # Delete mounted share
    $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    echo "[$current_time] Start delete mounted share. server:$server share:$share" >> $log_file_path
    net use \\$server\$share /delete >> $log_file_path
    if($?) {
        $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
        echo "[$current_time] Finish delete mounted share successfuly. server:$server share:$share" >> $log_file_path
    }
    else {
        $current_time = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
        echo "[$current_time] Error occurred while deleting mounted share. server:$server share:$share" >> $log_file_path
        exit
    }
}
