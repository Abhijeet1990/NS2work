netsim2.tcl
steps of execution:

Step1: simulates a network having two routers R1 and R2, 2 source src 1 and src 2 sending ftp packets to 2 reciever rcv1 and rcv2 over  TCP flavours TCP Reno
Step2 : first a simulator object named "ns_tcp" created
Step3 : a nam object named "assign2.nam" that would run the animation of the simulation
Step4 : a trace file assign2.tr is created to see the packet flow at different time instance
Step5: thrput1.tr, thrput2.tr and  thrput3.tr trace file created to store the average throughput response of H1->H3, H2->H4 and H5->H6 respectively
Step6: topology created by defining the node objects and building links among them by defining bandwidth along  eack link
Step7: using switch case structure link properties are set for different cases as asked in the assignment
Step8: TCP Agents of Reno and UDP agents are created 
Step9: FTP and CBR application to be sent from the sources are created 
Step10: H2,H4,H6 nodes are attached to the SINK agents...H1 and H3 nodes are attached to the TCP Agents using "attach-agent".. H5 attached to the UDP agent
Step11: SINK and TCP agents are connected using "connect" similarly NULL and UDP agents are connected
Step12: FTP applications are attached to the TCP sinks using "attach-agent"..similarly CBR application attached 
Step13: A record() function is written to calculate the average throughput and instantaneous throughput of three different source
Step14 : A finish() function is to execute the .nam and to plot the average throughput and instantaneous throughput curve from the data obtained in the thrput1.tr,thrput2.tr,thrput3.tr,instant1.tr,instant2.tr and instant3.tr trace files.

Execution of code for all the 6 cases:
ns netsim2.tcl RED 1
ns netsim2.tcl Droptail 1
ns netsim2.tcl RED 2
ns netsim2.tcl Droptail 2