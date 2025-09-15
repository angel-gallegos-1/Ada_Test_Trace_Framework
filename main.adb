--This file is a template for writing a trace-based test.  This file should be
--copied to the test's source directory and then modified to customize it to the
--target state machine being tested.  The state machine's transition function
--should be called; this should be a "pure" function that simply determines
--the output(s) based on the input(s) provided, where one of the inputs is
--the current state and one of the outputs is the new state.  Other inputs are
--indicators of events occurred, and other outputs are indicators of actions
--that should be taken.
--
--Most of the customization will be in the State_Machine_Wrapper procedure
--whose skeleton is defined below.


--ADD OTHER IMPORTS HERE FOR THE TARGET STATE MACHINE
with Kind2_Trace_Parser; 
with Ada.Directories; use Ada.Directories;
with Ada.Text_IO;use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Command_Line;


procedure Main is
  
   Input_Table: Kind2_Trace_Parser.Kind2_Table;
   Format_Table: Kind2_Trace_Parser.Kind2_Table;

   
  procedure Test_Traces_In_Directory(Inp_Path: String; Out_Dir: String) is


      --Call this function to add an output of the State Machine as String
      --to the end of the Row
      procedure Add_Output(Row: in out Kind2_Trace_Parser.Cell_Vectors.Vector;
                           Value: String) is

      begin 
         Row.Append(To_Unbounded_String(Value));
      end Add_Output;
      
      --Wrapper that calls the actual state machine.
      --Takes a vector and puts them into parameters to be used when
      --calling the actual state machine.
      --MODIFY TO REFLECT ACTUAL STATEMACHINE BEING USED
      --
      -- Here, the Row is  the set of values for the inputs  to the State Machine
      -- transition function.  The actual values are read from a CSV file that is
      -- emitted by kind2 when generating test traced.
      procedure State_Machine_Wrapper(Row: in out Kind2_Trace_Parser.Cell_Vectors.Vector) is
   
         --Declare Values variables to hold inputs from Row.
         --
         --  EXAMPLE: the row contains two integer values, for the "level"
         --  and "mode" inputs, where "mode" is actually an Enum of type
         --  Current_Mode (with values of On, Off, and Standby) defined
         --  elsewhere as:
         --
         --    type Current_Mode is (On, Off, Standby);
         --    for  Current_Mode is (On => 1, Off => 0, Standby => 2);
         --
         --  Knowing this, we could declare discrete variables for them here as:
         --
         --    inp_level : Integer;
         --    inp_mode  : Current_Mode;


         --Declare Value variables to hold outputs of the State Machine (change
         --to fit the actual state machine).
         --
         --  EXAMPLE: assume it will output the new mode is output along
         --  with a boolean indicating whether an alert is to be
         --  sounded (i.e. an Action that should be taken).
         --
         --    out_mode : Current_Mode;
         --    do_alert_action : Boolean;

      begin
            --Set Values to corresponding row values
            --
            --  EXAMPLE: For our example state machine described above, this
            --  would be:
            --
            --    inp_level := Integer'Value(To_String(Row(1)));
            --    inp_mode = Current_Mode'Val(Integer'Value(To_String(Row(2))));


            --Call State Machine being used
            --MODIFY TO RELECT ACTUAL STATE MACHINE BEING USED
            --
            --  EXAMPLE:
            --
            --    out_mode := Target.Transition(inp_level, inp_mode, do_alert_action);
            
         
            --Convert output Value(s) to String then Call Add_Output to have it
            --stored in the updated Row that will be written to the output file.
            --e.g. Enum-> Integer -> String -> to be added to end of the Row

            Add_Output(Row, Current_Mode'Enum_Rep(out_mode)'Image);
            Add_Output(Row, do_alert_action'Image);

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
            --State_Machine_Wrapper will call Add_Output on the returned values
            --from state machine
            State_Machine_Wrapper (E);

            --DEBUG: Step Output
            --Put_Line (E'Image);

            --DEBUG: Increment Counter
            Count:= Count + 1;

         end loop;
           
         Kind2_Trace_Parser.Table_to_File (Format_Table, Out_File_Name);

      end Process_Search_Item;


   -- The type Filter_Type specifies which directory entries are provided from a search operation.
   -- If the Directory component is True, directory entries representing directories are provided.
   -- If the Ordinary_File component is True, directory entries representing ordinary files are provided.
   -- If the Special_File component is True, directory entries representing special files are provided.
   Filter : Constant Filter_Type := (Ordinary_File => True,
                                       Special_File => False,
                                       Directory => True);

   begin
      -- Searches Given Directory and processes each file matching the given pattern and filter
      Search(Directory => Inp_Path,
             Pattern => ("*.csv"),
             Filter => Filter,
             Process => Process_Search_Item'Access);    

   end Test_Traces_In_Directory;


begin

   --This is the main function called to run the test.  It will utilize any
   --command-line arguments as described here and will prompt for input as
   --needed.
   --
   --Two arguments: input directory and output directory.
   --  1 argument given: Output defaults to outputs dir
   --  0 arguments given: User Prompted for input dir, Output default to outputs dir
   if(Ada.Command_Line.Argument_Count < 1) then

      if (Exists("outputs")) then
      
         Delete_Tree("outputs");
      
      end if;

      Create_Directory ("outputs");
   
      Put_Line ("Enter Input Trace Directory Name");
   
      Test_Traces_In_Directory (Get_Line, Current_Directory &"/outputs");
   
   elsif (Ada.Command_Line.Argument_Count = 1) then
      
      if (Exists("outputs")) then
      
         Delete_Tree("outputs");
      
      end if;

      Create_Directory ("outputs");
   
      Test_Traces_In_Directory(Ada.Command_Line.Argument(1),
                               Current_Directory &"/outputs");

   else  
      if (Exists(Ada.Command_Line.Argument(2))) then
      
         Delete_Tree(Ada.Command_Line.Argument(2));
      
      end if;
   
      Create_Directory (Ada.Command_Line.Argument(2));
      Test_Traces_In_Directory(Ada.Command_Line.Argument(1),
                               Ada.Command_Line.Argument(2));
   
   end if;

end Main;
