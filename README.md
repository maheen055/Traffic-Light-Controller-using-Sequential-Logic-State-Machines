# Traffic Light Controller using Sequential Logic & State-Machines

## Personal Project by Maheen Shoaib

### Project Overview

This project involves designing a Traffic Light Controller (TLC) using VHDL for sequential circuits, focusing on state machine design concepts, metastability issues, and synchronous design techniques. 

### Intended Learning Outcomes
By the end of this project, the following outcomes were achieved:
1. Understand state machine design concepts, including Moore or Mealy forms.
2. Understand the problems creating register “metastability.”
3. Learn the register synchronous design technique.

### Project Brief

Today's Traffic Light Controllers can be considered as continuously running state machines. They go through their sequences in a very predictable and repeatable manner. For policy (or legal) reasons, it is often critical that Traffic Light Controller (TLC) signals be bounded to some type of accurate timing. For this project, the TLC must change at about a 1Hz rate (i.e., 1 cycle per 1000 msec) to enable the TLC to go through its sequence appropriately.

Another feature included in this project is for external pedestrian input signals to the TLC to request changes to the traffic lights for crossing an intersection. Such requests are made “pending” until the appropriate time for switching.

This project uses a state machine design as the core design. As the state machine runs through its sequence, the appropriate outputs will illuminate the Traffic Lights being used in the intersection. The state machine may be based on either a Moore or the Mealy type of state machine. To eliminate all metastability issues with all sequential logic registers, the entire project design is driven by a common Global Clock for a synchronous design approach.

### Traffic Light Controller Display on the LogicalStep Board

The LogicalStep board does not have any RED or AMBER LEDs. So, the way that each column of traffic lights is shown on the board is on the seven-segment displays. They will be repurposed in a different kind of mode for this project. The seven-segment decoder components are no longer needed. Instead, just the three center segments of each display will be used.

For each seven-segment display:
- The BOTTOM segment (segment d) represents a GREEN LIGHT on a Traffic Light column.
- The CENTER Segment (segment g) represents an AMBER LIGHT on a Traffic Light column.
- The TOP Segment (segment a) represents a RED LIGHT on a Traffic Light column.

To activate the appropriate segment on a display, the respective Segment7_mux segment input should be set to a ‘1’. The specific inputs to use on the Segment7_mux for each seven-segment display can be determined by referring to previous work.

### Conclusion

This project provided valuable hands-on experience in designing a sequential logic system, understanding state machine concepts, and addressing metastability issues with synchronous design techniques.
