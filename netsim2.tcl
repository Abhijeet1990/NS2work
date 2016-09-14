#create simulator object.. create an object ns_tcp of class Simulator
set ns_tcp [new Simulator]
#create nam trace file
set ns_file [open assign2.nam w]
$ns_tcp namtrace-all $ns_file
#create trace file
set tf_file [open assign2.tr w]
set tp1 [open thrput1.tr w]
set tp2 [open thrput2.tr w]
set tp3 [open thrput3.tr w]
set inst1 [open instant1.tr w]
set inst2 [open instant2.tr w]
set inst3 [open instant3.tr w]

$ns_tcp trace-all $tf_file
set null [new Agent/LossMonitor]
if { $argc != 2 } {
puts "enter: <RED/DropTail>   <1/2>"
exit 0
}
set buffer_type [lindex $argv 0]
set cases [lindex $argv 1]
set prev1 0
set prev2 0
set prev3 0
set bw30_1 0
set bw30_2 0
set bw30_3 0
puts "type is $buffer_type"
puts "case is $cases"

#create topology of the given problem
set H1 [$ns_tcp node]  
set H2 [$ns_tcp node]  
set H3 [$ns_tcp node]   
set H4 [$ns_tcp node]   
set R1 [$ns_tcp node]    
set R2 [$ns_tcp node]
$ns_tcp duplex-link $H1 $R1 10Mb 1ms DropTail  
$ns_tcp duplex-link $H2 $R1 10Mb 1ms DropTail  
$ns_tcp duplex-link $H3 $R2 10Mb 1ms DropTail  
$ns_tcp duplex-link $H4 $R2 10Mb 1ms DropTail

switch $buffer_type {
  RED {
	Queue/RED thres_ 10
	Queue/RED maxthres_ 15
	Queue/RED linterm_ 50
	$ns_tcp duplex-link $R1 $R2 1Mb 10ms RED 
	puts "RED queue"
	}
Droptail {

	$ns_tcp duplex-link $R1 $R2 1Mb 10ms DropTail 
		puts "DropTail queue"
	}
default {
     puts "Invalid queue type"
   }
}

$ns_tcp queue-limit $R1 $R2 2000B

#create and attach the TCP agents
set tcp1 [ new Agent/TCP/Reno ]
set tcp2 [ new Agent/TCP/Reno ]
set tcpsink1 [ new Agent/TCPSink ]
set tcpsink2 [ new Agent/TCPSink ]

#attach TCP agents to respective nodes
$ns_tcp attach-agent $H1 $tcp1
$ns_tcp attach-agent $H2 $tcp2
$ns_tcp attach-agent $H3 $tcpsink1
$ns_tcp attach-agent $H4 $tcpsink2
$ns_tcp connect $tcp1 $tcpsink1
$ns_tcp connect $tcp2 $tcpsink2
#create application and attach to the TCP agents
set ftp1 [ new Application/FTP ]
set ftp2 [ new Application/FTP ]
$ftp1 attach-agent $tcp1
$ftp2 attach-agent $tcp2

if {$cases == 2} {
set H5 [ $ns_tcp node ]
set H6 [ $ns_tcp node ]
$ns_tcp duplex-link $H5 $R1 10Mb 1ms DropTail
$ns_tcp duplex-link $H6 $R2 10Mb 1ms DropTail
#create UDP agent
set udp1 [ new Agent/UDP ]

#attach UDP agent and null to respective nodes
$ns_tcp attach-agent $H5 $udp1
$ns_tcp attach-agent $H6 $null
$ns_tcp connect $udp1 $null
#create application
set cbr [ new Application/Traffic/CBR ]
$cbr set packetSize_ 100
$cbr set rate_ 1Mb
#attach cbr application to the UDP agent
$cbr attach-agent $udp1
$ns_tcp at 0.0 "$cbr start"
$ns_tcp at 180 "$cbr stop"
}

#create a record function to calculate average and instantaneous throughput 
proc record { } {
global tcpsink1 tcpsink2 null cases tp1 tp2 tp3 ns_tcp prev1 prev2 prev3 inst1 inst2 inst3 bw30_1 bw30_2 bw30_3
set bw0 [ $tcpsink1 set bytes_ ]
set bw1 [ $tcpsink2 set bytes_ ]
set bw2 [ $null set bytes_ ]
set time 1
set ctime [ $ns_tcp now]
if { $ctime==30 } {
set bw30_1 $bw0
set prev1 $bw0
puts "bw0 $bw30_1"
set bw30_2 $bw1
set prev2 $bw1
puts "bw1 $bw30_2"

if { $cases==2 } {
set bw30_3 $bw2
set prev3 $bw2
puts "bw2 $bw30_3"
}
}

if { $ctime > 30 } {
set averagetp1 [ expr ($bw0-$bw30_1)*8/(1024*($ctime-30)) ]
set instant1 [ expr ($bw0-$prev1)*8/(1024)]
set averagetp2 [ expr ($bw1-$bw30_2)*8/(1024*($ctime-30)) ]
set instant2 [ expr ($bw1-$prev2)*8/(1024)]
if { $cases == 2 } {
set averagetp3 [ expr ($bw2-$bw30_3)*8/(1024*($ctime-30)) ]
set instant3 [ expr ($bw2-$prev3)*8/(1024)]
puts $tp3 "$ctime $averagetp3"
puts $inst3 "$ctime $instant3"
set prev3 $bw2
}
puts $tp1 [format "$ctime %0.2f" [expr $averagetp1]]
puts $inst1 [format "$ctime %0.2f" [expr $instant1]]
puts $tp2 [format "$ctime %0.2f" [expr $averagetp2]]
puts $inst2 [format "$ctime %0.2f" [expr $instant2]]
set prev1 $bw0
set prev2 $bw1
}
$ns_tcp at [ expr $ctime + $time ] "record"
}

#define a finish procedure
proc finish {} {
global ns_tcp ns_file tf_file tp1 tp2 tp3 inst1 inst2 inst3 cases
$ns_tcp flush-trace
#close the nam trace file
close $ns_file  
close $tp1  
close $tp2  
close $tp3  
close $inst1  
close $inst2  
close $inst3  

switch $cases {
  1 {
	exec xgraph thrput1.tr thrput2.tr -geometry 800x400 &
	exec xgraph instant1.tr instant2.tr -geometry 800x400 &
	puts "$cases"
	}

 2 {
	exec xgraph thrput1.tr thrput2.tr -geometry 800x400 &
	exec xgraph instant1.tr instant2.tr -geometry 800x400 &
	puts "$cases"
	}

default {
     puts "Invalid case"
   }
}
#execute nam on the trace file
exec nam assign2.nam &
exit 0
}
$ns_tcp at 0.0 "$ftp1 start"
$ns_tcp at 0.0 "$ftp2 start"
$ns_tcp at 0.0 "record"
$ns_tcp at 180 "$ftp1 stop"
$ns_tcp at 180 "$ftp2 stop"
$ns_tcp at 180 "finish"
$ns_tcp run
