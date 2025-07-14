with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Text_IO; use Ada.Text_IO;

package Kind2_Trace_Parser  is
   
   --Row: a Vector of Cells
   --Containers based on generics, so you need a package declaration for custom type.
   --Element must have predefined max bounds during declaration if it is not unbounded
   package Cell_Vectors is new Ada.Containers.Vectors
   
     (Index_Type => Positive, Element_Type => Unbounded_String);

    use Cell_Vectors;

   --Table: a Vector of Rows
   package Row_Vectors is new Ada.Containers.Vectors
     (Index_Type => Positive, Element_Type => Cell_Vectors.Vector);
    use Row_Vectors;

   --Renaming for better Clarity
   subtype Kind2_Table is Row_Vectors.Vector;

   -- Finds Delimiter In a String.
   procedure Find_Delimiter(Stop_Idx: in out Positive;Delimiter: in Character;Line: in String);
   --Converts a File CSV to a Table
   function File_to_Table(File_Name: in String) return Kind2_Table;

   --Converts Table to a CSV File
   procedure Parse_Line(Line: in out String;Fields: out Cell_Vectors.Vector);


    function Format_Table(In_Table: Kind2_Table) return Kind2_Table;
  
  --Converts Table to a CSV File
  procedure Table_to_File(In_Table: Kind2_Table;File_Name: in String);


end Kind2_Trace_Parser;
