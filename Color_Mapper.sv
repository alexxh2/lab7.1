//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//                                                                       --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input  logic [9:0] DrawX, DrawY,
                       input logic [11:0] foreground, background, input logic IVn, input logic [10:0] char,
                       output logic [3:0]  Red, Green, Blue );
    

	  // use drawX and drawY to get address
     logic memory_address;

      // 4 -> 1
      // 16->1
      logic [13:0] char_index; // 0 to 2399
      assign char_index = DrawX[9:3] + (DrawY[9:4] * 80) // (draw x/8)
      logic [9:0] word_address // 0 to 600
      logic [1:0] character_offset; // 00 to 01 to 11 to 10 meaning 0 to 3
      assign word_address = char_index[13:2]; // picks the 0 to 600
      assign character_offset = char_index[1:0]; // mod 4


      logic [31:0] cur_vram;
      logic [7:0] cur_char_byte;
      cur_vram = ALL_VRAM[word_address];
      logic [31:0] control_vram;
      control_vram = ALL_VRAM[16'h258];


      if (character_offset == 2'b00) begin
         cur_char_byte = cur_vram[7:0];
      end else if (character_offset == 2'b01) begin
         cur_char_byte = cur_vram[15:8];
      end else if (character_offset == 2'b10) begin
         cur_char_byte = cur_vram[23:16];
      end else if (character_offset == 2'b11) begin
         cur_char_byte = cur_vram[31:24];
      end


      assign inversion_flag = cur_char_byte[7];
      assign character_code = cur_char_byte[6:0];

      logic [10:0] font_rom_addr;
      logic [2:0] pixelX;  // Ranges from 0 to 7
      logic [3:0] pixelY;  // Ranges from 0 to 15

      assign pixelX = DrawX[2:0]; // DrawX modulus 8
      assign pixelY = DrawY[3:0]; // DrawY modulus 16    

      assign font_rom_addr = {char_byte[6:0], pixelY} //2^4 = 16


      logic [7:0] font_data;

      font_rom font_rom_inst (
    .addr(font_rom_addr),
    .data(font_data)
      );

   logic pixel_bit;

   assign pixel_bit = font_data[7 - pixelX];  // Bits are ordered from MSB to LSB

   logic final_pixel_bit;

   always_comb begin
      if (inversion_flag) begin
         final_pixel_bit = ~pixel_bit;
      end else begin
         final_pixel_bit = pixel_bit;
      end
   end

always_comb begin : RGB_Display
    if (final_pixel_bit) begin
        // Foreground color
        Red   = control_vram[24:21];   // FGD_R
        Green = control_vram[20:17];   // FGD_G
        Blue  = control_vram[16:13];   // FGD_B
    end else begin
        // Background color
        Red   = control_vram[12:9];    // BKG_R
        Green = control_vram[8:5];     // BKG_G
        Blue  = control_vram[4:1];     // BKG_B
    end
end




   //DrawX9:3 gives char column from 0 to 79
   // 9:4 gies you 0 to 29


          // pass each char into font rom

     // multiply address by 4, /80 for row %80 for col, 80 cols, 30 rows

     // use axi read on address to get value 

     //slv_regs is register, every 8 bits is one char, first is inverse
     // if not inverted 1 is drawn w/ foreground, 0 w/ background



	  
	  
       // font_rom dpeends on vertical offset

   // init font rom

       //use control bit register 600 to decide to invert
       //if 1 then show fore then back, invert if 0
       
       
    /*   
    always_comb
    begin:RGB_Display

    
            Red = 4'hf - DrawX[9:6]; 
            Green = 4'hf - DrawX[9:6];
            Blue = 4'hf - DrawX[9:6];  
    end 
    */



endmodule




    int DistX, DistY, Size;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
  
    always_comb
    begin:Ball_on_proc
        if ( (DistX*DistX + DistY*DistY) <= (Size * Size) )
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
       
    always_comb
    begin:RGB_Display
        if ((ball_on == 1'b1)) begin 
            Red = 4'hf;
            Green = 4'h7;
            Blue = 4'h0;
        end       
        else begin 
            Red = 4'hf - DrawX[9:6]; 
            Green = 4'hf - DrawX[9:6];
            Blue = 4'hf - DrawX[9:6];
        end      
    end 