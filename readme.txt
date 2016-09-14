
ns2.tcl
steps of execution:

Step1: simulates a network having two routers R1 and R2, 2 source src 1 and src 2 sending ftp packets to 2 reciever rcv1 and rcv2 over 2 TCP flavours TCP Vegas and TCK Sack
Step2 : first a simulator object named "ns_tcp" created
Step3 : a nam object named "assign.nam" that would run the animation of the simulation
Step4 : a trace file assign.tr is created to see the packet flow at different time instance
Step5: tp1.tr, tp2.tr and  rp.tr trace file created to store the throughput response of src1->rcv1 and src2->rcv2 alongwith the ratio of throughput calculation at every 5 sec 
Step6: topology created by defining the node objects and building links among them by defining bandwidth along  eack link
Step7: using switch case structure link properties are set for different cases as asked in the assignment
Step8: TCP Agents of Vegas,SACk and SINK created
Step9: FTP application to be sent from the sources are created
Step10: rcv nodes are attached to the SINK agents...src nodes are attached to the TCP Agents using "attach-agent"
Step11: SINK and TCP agents are connected using "connect"
Step12: FTP applications are attached to the TCP sinks using "attach-agent"
Step13: A record() function is written to calculate the throughput and ratio of throughputs of two different source
Step14 : A finish() function is to execute the .nam and to plot the throughput curve from the data obtained in the tp1.tr and tp2.tr trace files
Step15: Then the simulator runs for 400s

Execution of code for all the 6 cases:
ns ns2.tcl VEGAS 1
ns ns2.tcl VEGAS 2
ns ns2.tcl VEGAS 3
ns ns2.tcl SACK 1
ns ns2.tcl SACK 2
ns ns2.tcl SACK 3
