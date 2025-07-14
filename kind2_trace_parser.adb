--Used for trimming leading or trailing space in cells
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
--Used for Reading file size
with Ada.Directories; use Ada.Directories;
--Used for debugging and file input/output
with Ada.Text_IO; use Ada.Text_IO;

package body Kind2_Trace_Parser is




   procedure Find_Delimiter(Stop_Idx: in out Positive;Delimiter: in Character;Line: in String) is
   
   begin

   while Stop_Idx <= Line'Last and then Line(Stop_Idx) /= Delimiter loop
            --sets stop to comma position or last
            Stop_Idx := Stop_Idx + 1;
   end loop;

   end Find_Delimiter;




   -- Parses a CSV line into fields
   procedure Parse_Line(Line: in out String; Fields: out Cell_Vectors.Vector) is
      
      Start : Positive := Line'First;
      Stop  : Positive :=Start;

   begin
      while Start <= Line'Last loop
         
        -- Find the next comma or end of line
        Find_Delimiter(Stop,',',Line);
         --  while Stop <= Line'Last and then Line(Stop) /= ',' loop
         --     --sets stop to comma position or last
         --     Stop := Stop + 1;
         --  end loop;

         if Stop >= (Line'Last + 1) then

            -- Convert the last field (from Start to end of line) to Unbounded_String
            Fields.Append(To_Unbounded_String(
               Trim(Line(Start .. Line'Last), Ada.Strings.Both)));
            
            exit;

         else

            -- Extract field text up to comma and convert to Unbounded_String
            Fields.Append(To_Unbounded_String(
               Trim(Line(Start .. Stop - 1), Ada.Strings.Both)
            ));

            
            --Set Start to next char after comma
            Start := Stop +1;
            --Set stop to next char after comma
            Stop:=Start;
         end if;
      end loop;
      
   end Parse_Line;





   --Converts a File CSV to a Table
   function File_to_Table(File_Name: in String) return Kind2_Table is 
      
      --The number of stream elements contained in the file
      F_Size: constant File_Size:= Size(File_Name);
      Int_F_Size: constant Integer:= Integer(F_Size);

      --Initialize Kind2_Table Object for input file
      Input_Table: Kind2_Table;

      --Current Max length for a line (can be changed later)
      Line: String (1..Int_F_Size);

      --Row Vector to hold cell values for current row
      Row_Cells  : Cell_Vectors.Vector;
      
      --To be used to trim line data down in case where line length < Max Length 
      Last    : Natural;

      File: File_Type;

   begin 

   
         Open(File, In_File, File_Name);


      while not End_Of_File(File) loop
     
            Get_Line(File, Line, Last);

            --Parses line and fills Row_Cells vector
            Parse_Line(Line(1 .. Last), Row_Cells);
            
            --Adds Row to Input_Table (Copies data to Table at last position)
            Input_Table.Append(Row_Cells);

            --Debug Statement
            --for E of Row_Cells loop

               --Put(To_String(E)& " ");

            --end loop;

            --New_Line;
            --Clears Row_Cells to be used for next iteration
            Row_Cells.Clear;
            
      end loop;
      
      Close (File);
      
      return Input_Table;
   
   end File_to_Table;




     --Formats table with the steps columns as rows
     function Format_Table(In_Table: Kind2_Table) return Kind2_Table is 

        --Output table that has been formatted
      Out_Table: Kind2_Table;

      
      --Offset for the 2 Header Columns in Kind2 Traces
      Header_Offset: constant Integer:= 2;



      --Declaration and initializaiton of a matrix data structure for intermediate processing
      type Matrix is array (In_Table(1).First_Index+Header_Offset .. In_Table(1).Last_Index, In_Table.First_Index .. In_Table.Last_Index) of Unbounded_String;
      M: Matrix  :=
      (others =>
         (others => To_Unbounded_String ("")));

      --current row vector used when fil
      Row_Cells: Cell_Vectors.Vector;
      begin

         --Transpose Table info into matrix
         for I in  In_Table.First_Index .. In_Table.Last_Index loop
            
           for J in  In_Table(1).First_Index+Header_Offset .. In_Table(1).Last_Index loop
                  M(J,I):=In_Table(I)(J);
            
                
           end loop;
           
         end loop;

         --Copy matrix data to Table 
         for K in M'Range (1) loop
            
            for L in M'Range (2) loop
               
               Row_Cells.Append(M(K,L));
      
            end loop;

               Out_Table.Append(Row_Cells);
               Row_Cells.Clear;
              
         end loop;



       return Out_Table;
     end Format_Table;


   --  Converts Table to a CSV File
   procedure Table_to_File(In_Table: Kind2_Table;File_Name: in String) is 

      F         : File_Type;
   
      -- Unbounded String to be used to put each row in CSV format
      Row_U_String : Unbounded_String:= To_Unbounded_String ("");
   begin

      Create(F, Out_File, File_Name);

      --Iterate through each row
      for Row in In_Table.Iterate loop
            
         for Cell in In_Table(Row).Iterate loop

            -- If the current cell is the last one in the row only add the cell with no comma
            if  Integer(In_Table(Row).Last_Index) = To_Index(Cell) then
            
               Append(Row_U_String, In_Table(Row)(Cell));
            
            else  
              
               Append(Row_U_String, In_Table(Row)(Cell));
               Append(Row_U_String, ",");
            
            end if;

         end loop;
         
         Put_Line (F, To_String(Row_U_String));
         
         Row_U_String:= To_Unbounded_String ("");
         
      end loop;
      
      Close (F);
   
   end Table_to_File;

end Kind2_Trace_Parser;
