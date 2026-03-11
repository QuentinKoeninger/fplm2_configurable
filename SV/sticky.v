/******************************************************************************
*@module    Fast Sticky Computation [Yu & Zyner]	
*@author	TuanND
*@date 		2017-03-27
*@desc      Trick to generate sticky bit without CPA 
******************************************************************************/

module  sticky(Carry, Sum, Sticky); 
   parameter	WIDTH	=	51;

   input   [WIDTH-1:0] Carry, Sum;   
   output 			Sticky;

   wire [WIDTH-1:0] P, T;
   wire [WIDTH:0] H;
   assign P = Carry ^ Sum; //pi = si ^ ci
   assign H[WIDTH:1] = Carry | Sum; //hi = si + ci
   assign H[0] = 0;
   assign T = P ^ H[WIDTH-1:0];//ti = pi ^ hi-1 

   assign Sticky = |T;//one detector;

endmodule
