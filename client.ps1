[CmdletBinding()]

param(
	[string]$serverip="127.0.0.1",
	[int]$port=15000
)

function send-msg ($message, $port, $server) {
	# Create IP Endpoint 
	#$endpoint = New-Object System.Net.IPEndPoint $address, $port 
	# Create Socket 
	write-host connecting to $server`:$port
	$endpoint = new-object System.Net.IPEndPoint ([System.Net.ipaddress]::any, $null)
	#$client = New-Object System.Net.Sockets.TcpClient $server, $port
	$client = [net.sockets.tcpclient]$endpoint
	
	while (!$client.connected)
	{
		try{
			$client.connect($server, $port)
			break
		}catch{
			start-sleep -s 2
			write-host "Searching for server..."
		}
	}
	
	
	$Global:server_stream = $client.GetStream()
	$username = "user1"
	$message = [text.Encoding]::Ascii.GetBytes($username)
	
	$server_stream.write($message, 0, $message.length)
	$server_stream.flush()
	
	
	while ($client.connected) # Detects disconnect on message send failed
	{
		write-host connected $client.connected
		write-host active $client.active
		[byte[]]$byte_stream = New-Object byte[] 200KB
		
		try{
			$buff_size = $client.ReceiveBufferSize
			write-host buff size $buff_size
			$return = $server_stream.Read($byte_stream, 0, $buff_size)
			If ($return -gt 0)
			{
				$response = [System.Text.Encoding]::ASCII.GetString($byte_stream[0..($return - 1)])
				write-host $response
			}
		}catch{
			write-host "Connection Lost..."
			break
		}

		
		
		
	}
	
	
	
	$server_stream.Dispose()
	$client.Dispose()
	exit
	
}





$serverip = [system.net.IPAddress]::Parse($serverip) 
send-msg "hello" $port $serverip






<#}>
			catch
			{
				#Connection to server has been closed                            
				write-host "Connection closed..."
				write-host $_.exception.message
				write-host $_.exception.itemname
				Break
			}#>



<#

	while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
	{
		$bytes[0..($i-1)]|%{$_}
		if ($Echo)
		{
			$stream.Write($bytes,0,$i)
		}
	}











	$saddrf   = [System.Net.Sockets.AddressFamily]::InterNetwork 
	$stype    = [System.Net.Sockets.SocketType]::Dgram 
	$ptype    = [System.Net.Sockets.ProtocolType]::UDP 
	$sock     = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype 
	$sock.TTL = 26 
	
	$sock.bind($endpoint)

	write-host Listening on port $port
	$sock.listen()











	#$client = $sock.accepttcpclient()

	If ($client -ne $Null) {
		$stream = $client.GetStream()
		Do {
			#Write-Host 'Processing Data'
			Write-Verbose ("Bytes Left: {0}" -f $Client.Available)
			$Return = $stream.Read($byte, 0, $byte.Length)
			$String += [text.Encoding]::Ascii.GetString($byte[0..($Return-1)])
           	} While ($stream.DataAvailable)
	}
	
	
	
	
	
	$reader = New-Object System.IO.StreamReader $stream
	do {

		$line = $reader.ReadLine()
		write-host $line -fore cyan
	} while ($line -and $line -ne ([char]4))


	$reader.Dispose()
	$stream.Dispose()
	$client.Dispose()
	$listener.stop()
#>


<#
	$saddrf   = [System.Net.Sockets.AddressFamily]::InterNetwork 
	$stype    = [System.Net.Sockets.SocketType]::Dgram 
	$ptype    = [System.Net.Sockets.ProtocolType]::UDP 
	$sock     = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype 
	$sock.TTL = 26 
	
	sock.connect($endpoint)
	
	# Create encoded buffer 
	$enc     = [System.Text.Encoding]::ASCII 
	$message = "test`n"*10 
	$buffer  = $Enc.GetBytes($Message)
#>









