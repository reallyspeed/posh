[CmdletBinding()]

param(
	[int]$port=15000
)

$Global:clients = [hashtable]::Synchronized(@{})
$Global:client_threads = [hashtable]::Synchronized(@{})
$Global:remove_client_queue = [System.Collections.Queue]::Synchronized((New-Object System.collections.queue))
$Global:message_queue = [System.Collections.Queue]::Synchronized((New-Object System.collections.queue))


$broadcast_timer = New-Object Timers.Timer
$broadcast_timer.Enabled = $true
$broadcast_timer.Interval = 1000 



function create_connection ($client)
{
	$stream = $client.getstream()
	$username = ""
	[byte[]]$bytes = New-Object byte[] 5KB
	
	do
	{
		write-verbose ("Bytes Left: {0}" -f $client.Available)
		$return = $stream.Read($bytes, 0, $bytes.Length)
		$username += [text.Encoding]::Ascii.GetString($bytes[0..($return-1)])
	} while ($stream.DataAvailable)
	
	write-host $username
	# Add client
	$clients[$username] = $client
	
	#Send list of online users to client
	$broadcast_stream = $client.GetStream()
	$broadcast_bytes = ([text.encoding]::ASCII).GetBytes("You are connected")
	$broadcast_stream.Write($broadcast_bytes,0,$broadcast_bytes.Length)
	$broadcast_stream.Flush()
	
	
	
	$client_runspace = [RunSpaceFactory]::CreateRunspace()
	$client_runspace.Open()
	$client_runspace.SessionStateProxy.setVariable("clients", $clients)
	$client_runspace.SessionStateProxy.setVariable("client_messages", $message_queue)
	$client_runspace.SessionStateProxy.setVariable("remove_client_queue", $remove_client_queue)
	$client_runspace.SessionStateProxy.setVariable("username", $username)
	$client_shell = [PowerShell]::Create()
	$client_shell.Runspace = $client_runspace 
	$sb =
	{
		#Code to kick off client connection monitor and look for incoming messages.
		$client = $clients[$username]
		$stream = $client.GetStream()
		
		#While client is connected to server, check for incoming traffic
		While ($true) {                                              
			[byte[]]$bytes = New-Object byte[] 200KB
			$buff_size = $client.ReceiveBufferSize
			$return = $stream.Read($bytes, 0, $buff_size)  
			If ($return -gt 0)
			{
				$message_queue.Enqueue([System.Text.Encoding]::ASCII.GetString($bytes[0..($return - 1)]))
			} Else {
				$clients.Remove($username)              
				$remove_client_queue.Enqueue($username)
				# Removing Client
				Break
			}
		}
		
		$client.client.shutdown([System.Net.Sockets.SocketShutdown]::Both)
		$client.dispose()
		$stream.dispose()

	}
	$job = "" | Select Job, PowerShell
	$job.PowerShell = $client_shell
	$job.job = $client_shell.AddScript($sb).BeginInvoke()
	$client_threads[$username] = $job                                          

}












$broadcast_timer.start()

$listener = [System.Net.Sockets.TcpListener]$port
$listener.Start()

write-host ("{0} >> Server Started on port {1}" -f (Get-Date).ToString(), $port)


# TODO Start remove queue monitor


$Global:runspace_main = [RunSpaceFactory]::CreateRunspace()
$runspace_main.Open()
$runspace_main.SessionStateProxy.setVariable("clients", $clients)
$runspace_main.SessionStateProxy.setVariable("listener", $listener)
$Global:newPowerShell = [PowerShell]::Create()
$powershell_main.Runspace = $runspace_main

$main_loop =
{
	while ($true)
	{
		$client = $listener.AcceptTcpClient() # block until connection
		If ($client -ne $Null)
		{
			create_connection $client
		}
		else
		{
			[console]::writeline("Null Client...")
			break
		}
		
		### DEBUG #########################
		break
	}
	
	
	$listener.stop()
	exit

}



	
































