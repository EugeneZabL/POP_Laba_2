with Ada.Text_IO; use Ada.Text_IO;
with ada.numerics.discrete_random;


procedure Main is

   dim : constant integer := 100000;
   thread_num : constant integer := 5;

   arr : array(1..dim) of integer;

   procedure Init_Arr is
   type randRange is new Integer range 1..dim;
   package Rand_Int is new ada.numerics.discrete_random(randRange);
   use Rand_Int;
   gen : Generator;
   num : randRange;
   begin
      for i in 1..dim loop
         reset(gen);
         num := random(gen);
         arr(i) := Integer(num);
      end loop;
      reset(gen);
      num := random(gen);
      arr(Integer(num)) := -1;
      Put_Line("Id with zero is - "&num'img);
      Put_Line("\\\\\\\\\\\\\\\\");
   end Init_Arr;

   function Find_min(start_index, finish_index : in integer) return integer is
      indexT : Integer := start_index;
   begin
      for i in start_index..finish_index loop
         if arr(i) < arr(indexT) then
            indexT := integer(i);
         end if;
      end loop;
      return indexT;
   end Find_min;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_Find_min(indexT : in Integer);
      entry get_Min(indexT : out Integer);
   private
      tasks_count : Integer := 0;
      indexT1 : Integer := 1;
   end part_manager;

   protected body part_manager is
      procedure set_Find_min(indexT : in Integer) is
      begin
         if arr(indexT)<arr(indexT1) then
            indexT1 := indexT;
            end if;
         tasks_count := tasks_count + 1;
      end set_Find_min;

      entry get_Min(indexT : out Integer) when tasks_count = thread_num is
      begin
         indexT := indexT1;
      end get_Min;

   end part_manager;

   task body starter_thread is
      indexT : Integer := 1;
      start_index, finish_index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      indexT := Find_min(start_index  => start_index,
                      finish_index => finish_index);
      part_manager.set_Find_min(indexT);
   end starter_thread;

   function parallel_Min return Integer is
      indexT : integer := 0;
      helpForIndex : integer := dim /thread_num;
      thread : array(1..thread_num) of starter_thread;
   begin
      for i in 1..thread_num loop
         thread(i).start(((i-1)*helpForIndex) + 1, helpForIndex*(i));
         end loop;
      part_manager.get_Min(indexT);
      return indexT;
   end parallel_Min;

   answer : Integer := 0;

begin
   Init_Arr;

   answer := Find_min(1, dim);
   Put_Line(answer'img);
   Put_Line(arr(answer)'img);

   answer := parallel_Min;
   Put_Line(answer'img);
   Put_Line(arr(answer)'img);
end Main;
