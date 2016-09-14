#create simulator object.. create an object ns_tcp of class Simulator
set ns_tcp [new Simulator]

#create nam trace file

set ns_file [open assign.nam w]
$ns_tcp namtrace-all $ns_file

#create trace file

set tf_file [open assign.tr w]
set tp1 [open tp1.tr w]
set tp2 [open tp2.tr w]
set rp [open rp.tr w]
$ns_tcp trace-all $tf_file

#types and cases holds the command line arguments to test for 2 flavours of TCP and 3 different cases
set types [lindex $argv 0]
set cases [lindex $argv 1]

puts "type is $types"
puts "case is $cases"

#create topology of the given problem
set src1 [$ns_tcp node]  
set src2 [$ns_tcp node]  
set rcv1 [$ns_tcp node]   
set rcv2 [$ns_tcp node]   
set R1 [$ns_tcp node]    
set R2 [$ns_tcp node]

#create links between nodes

switch $cases {
   1 {
     $ns_tcp duplex-link $src1 $R1 10Mb 5ms DropTail
	$ns_tcp duplex-link $src2 $R1 10Mb 12.5ms DropTail
	$ns_tcp duplex-link $rcv1 $R2 10Mb 5ms DropTail
	$ns_tcp duplex-link $rcv2 $R2 10Mb 12.5ms DropTail
	$ns_tcp duplex-link $R1 $R2 1Mb 5ms DropTail
   }
   2 {
     $ns_tcp duplex-link $src1 $R1 10Mb 5ms DropTail
	$ns_tcp duplex-link $src2 $R1 10Mb 20ms DropTail
	$ns_tcp duplex-link $rcv1 $R2 10Mb 5ms DropTail
	$ns_tcp duplex-link $rcv2 $R2 10Mb 20ms DropTail
	$ns_tcp duplex-link $R1 $R2 1Mb 5ms DropTail
   }

   3 {
     $ns_tcp duplex-link $src1 $R1 10Mb 5ms DropTail
	$ns_tcp duplex-link $src2 $R1 10Mb 27.5ms DropTail
	$ns_tcp duplex-link $rcv1 $R2 10Mb 5ms DropTail
	$ns_tcp duplex-link $rcv2 $R2 10Mb 27.5ms DropTail
	$ns_tcp duplex-link $R1 $R2 1Mb 5ms DropTail
   }
default {
     puts "Invalid case"
   }
  
}
#create tcp agents 

set tcp1 [new Agent/TCP/Sack1]
set tcp2 [new Agent/TCP/Sack1]
set tcp3 [new Agent/TCP/Vegas]
set tcp4 [new Agent/TCP/Vegas]
set sink1 [new Agent/TCPSink]
set sink2 [new Agent/TCPSink]
set ftp [new Application/FTP]
set ftp1 [new Application/FTP]
$ns_tcp attach-agent $rcv1 $sink1
$ns_tcp attach-agent $rcv2 $sink2

#create ftp application and attach to the tcp agents for both the flavours
switch $types {
  VEGAS {

	$ns_tcp attach-agent $src1 $tcp3
	$ns_tcp attach-agent $src2 $tcp4
	$ns_tcp connect $tcp3 $sink1
	$ns_tcp connect $tcp4 $sink2
	$ftp attach-agent $tcp3
	$ftp1 attach-agent $tcp4
	}

SACK {

	$ns_tcp attach-agent $src1 $tcp1
	$ns_tcp attach-agent $src2 $tcp2
	$ns_tcp connect $tcp1 $sink1
	$ns_tcp connect $tcp2 $sink2
	$ftp attach-agent $tcp1
	$ftp1 attach-agent $tcp2
	}

default {
     puts "Invalid type"
   }
}
#create a record function to calculate throughput
proc record {} {
global sink1 sink2 throughput throughput1 ns_tcp rp tp1 tp2
set time 20
set bw0 [$sink1 set bytes_]
set bw1 [$sink2 set bytes_]
set ctime [$ns_tcp now] 
set throughput [expr ($bw0)*8/($ctime)]
set throughput1 [expr ($bw1)*8/($ctime)]
set ratio [expr double($throughput)/double($throughput1)]
if {$ctime >= 50} {
puts $rp [format "ratio of throughputs at [expr $ctime] is %0.2f " [expr $ratio]]
puts $tp1 "$ctime [expr $throughput]"
puts $tp2 "$ctime [expr $throughput1]"
}
$ns_tcp at [expr $time+$ctime] "record"
}

#define a finish procedure
proc finish {} {
global ns_tcp ns_file
$ns_tcp flush-trace
#close the nam trace file
close $ns_file  
#execute nam on the trace file
exec nam assign.nam &
exec xgraph tp1.tr tp2.tr -geometry 800x400 &
exit 0
}


#run the simualation
$ns_tcp at 0 "$ftp start"
$ns_tcp at 0 "$ftp1 start"
$ns_tcp at 1 "record"
$ns_tcp at 400 "$ftp stop"
$ns_tcp at 400 "$ftp1 stop"
$ns_tcp at 401 "finish"

$ns_tcp run
