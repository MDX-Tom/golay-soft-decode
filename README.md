# golay-ml-decode
 (24,12) Golay code encoder and MAP soft-decision decoder for Matlab.
 
 The decoding method is based on a simple test for a noisy received codeword with all legal codewords, 
 finding the legal codeword with the minimum Euclidean Distance from the received codeword as the correct one.

 Theoretically, MAP soft-decision decoding can correct 6 bits of error per codeword, while 
 hard decision decoding can only correct 3. 
 
 Simulation results are represented below.
 
<image src="Plots/ber.png"/>
