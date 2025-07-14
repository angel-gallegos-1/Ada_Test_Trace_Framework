with Kind2_Trace_Parser; 
with Ada.Directories; use Ada.Directories;
with Ada.Text_IO;use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Command_Line;
with Alarm;use Alarm;
with Starter;use Starter;
procedure Main is
  
   Input_Table: Kind2_Trace_Parser.Kind2_Table;
   Format_Table: Kind2_Trace_Parser.Kind2_Table;

   



  procedure Search_Directory(Inp_Path: String;Out_Dir: String) is


      --Call this function to add output of State Machine as String to end of Row
      procedure Add_Output(Row: in out Kind2_Trace_Parser.Cell_Vectors.Vector; Value: String) is 

      begin 
         Row.Append(To_Unbounded_String(Value));
      end Add_Output;
      
      --Wrapper that calls actual state machine 
      --takes vector and puts them into parameters to be used on actual 
      --MODIFY TO REFLECT ACTUAL STATEMACHINE BEING USED
      procedure State_Machine_Wrapper(Row: in out Kind2_Trace_Parser.Cell_Vectors.Vector) is
   
         --Values to hold inputs from Row
         test_alarm_state: Alarm_State;
         test_starter_state: Starter_State;
         test_alarm_button: Boolean;

         --Value to hold output of State Machine (change to fit state machine)
         Out_Val: A_State;

      begin
            --Set Values to corresponding row values
            test_alarm_state.state := A_State'Val(Integer'Value(To_String(Row(2))));

            test_starter_state.state := S_State'Val(Integer'Value(To_String(Row(1))));

            --Custom Logic for String -> Boolean Conversion 
            if Row(3) = "true" then
               test_alarm_button := True;
            elsif Row(3) = "false" then
               test_alarm_button := False;
            else
               raise Constraint_Error with "Invalid value for test_alarm_button: " & To_String(Row(3));
            end if;


            --Convert String Representation of inputs to Proper Ada type Equivalent (change to fit state machine)
            --MODIFY TO RELECT ACTUAL STATE MACHINE BEING USED
            Out_Val:=Alarm.Transition(test_alarm_state.state,test_starter_state,test_alarm_button);
         
            --Convert Value to String then Call Add_Output to have Value stored in the Row. 
            --Enum-> Integer -> String -> to be added to end of the Row
            Add_Output(Row, A_State'Enum_Rep(Out_Val)'Image);

      end State_Machine_Wrapper;



      --Procedure to process CSV in Test Trace Directory
      procedure Process_Search_Item(Search_Item : in Directory_Entry_Type) is
         --DEBUG: Step Counter
         Count: Integer:=0;
         Out_File_Name: String:= Out_Dir &"/" &"out_" & Simple_Name(Directory_Entry =>Search_Item);
      begin
         
         --Convert Test Trace to Table data structure
         Input_Table:= Kind2_Trace_Parser.File_to_Table(Full_Name(Directory_Entry => Search_Item));
         
         --Format data structure for proper State Machine processing 
         Format_Table:= Kind2_Trace_Parser.Format_Table(Input_Table);

         
         

         for E of Format_Table loop

            --Put_Line ("Step: "& Count'Image& " " &E'Image);
         
            --Call state machine code on column data
            --State Machine Wrapper will call add output on returned values from state machine
            State_Machine_Wrapper (E);

            --DEBUG: Step Output
            --Put_Line (E'Image);

            --DEBUG: Increment Counter
            Count:= Count + 1;

         end loop;
         
           
           Kind2_Trace_Parser.Table_to_File (Format_Table, Out_File_Name);
         



      end Process_Search_Item;


   --The type Filter_Type specifies which directory entries are provided from a search operation. 
   --If the Directory component is True, directory entries representing directories are provided. 
   --If the Ordinary_File component is True, directory entries representing ordinary files are provided. 
   --If the Special_File component is True, directory entries representing special files are provided.
   Filter : Constant Filter_Type := (Ordinary_File => True,
                                       Special_File => False,
                                       Directory => True);

   begin
      -- Searches Given Directory and processes each file matching the given pattern and filter
      Search(Directory => Inp_Path,
             Pattern => ("*.csv"),
             Filter => Filter,
             Process => Process_Search_Item'Access);    

   end Search_Directory;


   
begin

   

   --Two  arguments input directory and output folder. 
   --1 argument given: Output default to outputs dir
   --0 arguments given: User Prompted for input dir, Output default to outputs dir
   if(Ada.Command_Line.Argument_Count <1) then

      if (Exists("outputs")) then
      
         Delete_Tree("outputs");
      
      end if;

      Create_Directory ("outputs");
   
      Put_Line ("Enter Input Trace Directory Name");
   
      Search_Directory (Get_Line,Current_Directory &"/outputs");
   
   elsif (Ada.Command_Line.Argument_Count =1) then 
      
      if (Exists("outputs")) then
      
         Delete_Tree("outputs");
      
      end if;

      Create_Directory ("outputs");
   
      Search_Directory(Ada.Command_Line.Argument(1),Current_Directory &"/outputs");

   else  
      if (Exists(Ada.Command_Line.Argument(2))) then
      
         Delete_Tree(Ada.Command_Line.Argument(2));
      
      end if;
   
      Create_Directory (Ada.Command_Line.Argument(2));
      Search_Directory(Ada.Command_Line.Argument(1), Ada.Command_Line.Argument(2));
   
   end if;

end Main;