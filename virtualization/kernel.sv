/*=============================================================================
** Module: kernel.sv
** Description:
**              kernel class
** Author: Taeyoung Kong
** Change history:
**  10/25/2020 - Implement the first version
**===========================================================================*/

import "DPI-C" function chandle parse_metadata(string filename);
import "DPI-C" function chandle get_place_info(chandle info);

import "DPI-C" function int get_num_inputs(chandle info);
import "DPI-C" function int get_num_outputs(chandle info);

import "DPI-C" function string get_placement_filename(chandle info);
import "DPI-C" function string get_bitstream_filename(chandle info);
import "DPI-C" function string get_input_filename(chandle info, int index);
import "DPI-C" function string get_output_filename(chandle info, int index);
import "DPI-C" function int get_input_size(chandle info, int index);
import "DPI-C" function int get_output_size(chandle info, int index);

typedef enum int {
    IDLE = 0,
    QUEUED = 1,
    CONFIG = 2,
    RUNNING = 3,
    FINISH = 4
} app_state_t;

typedef struct packed {
    int unsigned addr;
    int unsigned data;
} bitstream_entry_t;

typedef byte unsigned data_array_t[$];
typedef bitstream_entry_t bitstream_t[$];

class Kernel;
    static int cnt = 0;
    int id;

    chandle meta_info, place_info;

    string placement_filename;
    string bitstream_filename;
    string input_filenames[];
    string output_filenames[];

    int num_inputs;
    int num_outputs;

    int input_size[];
    int output_size[];

    // queue to store data
    data_array_t input_data[];
    data_array_t output_data[];
    data_array_t gold_data[];

    // queue to store bitstream
    bitstream_t  bitstream;

    // app state
    app_state_t  app_state;

    extern function new(string meta_filename);
    extern function void display();
    extern function data_array_t get_input_data(int idx);
    extern function data_array_t get_gold_data(int idx);
    extern function void print_input(int idx);
    extern function void print_output(int idx);
    extern function void print_gold(int idx);
    extern function void print_bitstream();
    extern function void compare();
    extern function void assert_(bit cond, string msg);
endclass

function Kernel::new(string meta_filename);
    id = cnt++;
    app_state = IDLE;


    meta_info = parse_metadata(meta_filename);
    assert_(meta_info != null, $sformatf("Unable to find %s", meta_filename));

    placement_filename = get_placement_filename(meta_info);
    bitstream_filename = get_bitstream_filename(meta_info);

    place_info = get_place_info(meta_info);
    assert_(place_info != null, $sformatf("Unable to find %s", placement_filename));

    num_inputs = get_num_inputs(place_info);
    num_outputs = get_num_outputs(place_info);

    input_filenames = new[num_inputs];
    input_data = new[num_inputs];
    input_size = new[num_inputs];

    output_filenames = new[num_outputs];
    output_data = new[num_outputs];
    output_size = new[num_outputs];
    gold_data = new[num_outputs];

    for (int i = 0; i < num_inputs; i++) begin
        input_filenames[i] = get_input_filename(meta_info, i);
        input_size[i] = get_input_size(place_info, i);
        input_data[i] = get_input_data(i);
    end

    for (int i = 0; i < num_outputs; i++) begin
        int x, y;
        output_filenames[i] = get_output_filename(meta_info, i);
        output_size[i] = get_output_size(place_info, i);
        gold_data[i] = get_gold_data(i);
    end
endfunction

function data_array_t Kernel::get_input_data(int idx);
    byte unsigned result[] = new[input_size[idx]];
    int fp = $fopen(input_filenames[idx], "rb");
    assert_(fp != 0, "Unable to read input file");
    for (int i = 0; i < input_size[idx]; i++) begin
        byte value;
        int code;
        code = $fread(value, fp);
        assert_(code == 1, $sformatf("Unable to read input data"));
        result[i] = value;
    end
    $fclose(fp);
    return result;
endfunction

function data_array_t Kernel::get_gold_data(int idx);
    byte unsigned result[] = new[output_size[idx]];
    int fp = $fopen(output_filenames[idx], "rb");
    assert_(fp != 0, "Unable to read output file");
    for (int i = 0; i < output_size[idx]; i++) begin
        byte value;
        int code;
        code = $fread(value, fp);
        assert_(code == 1, $sformatf("Unable to read output data"));
        result[i] = value;
    end
    $fclose(fp);
    return result;
endfunction

// assertion
function void Kernel::assert_(bit cond, string msg);
    assert (cond) else begin
        $display("%s", msg);
        $stacktrace;
        $finish(1);
    end
endfunction

function void Kernel::display();
    $display("Kernel number: %0d\n", id); 
endfunction

function void Kernel::compare();
    assert (gold_data.size() != output_data.size())
    else begin
        $display("APP[%0d], gold data size is %0d, output data size is %0d", id, gold_data.size(), output_data.size());
        $finish(2);
    end
    for (int i = 0; i < gold_data.size(); i++) begin
        assert_(gold_data[i] == output_data[i],
                $sformatf("APP[%0d], pixel[%0d] Get %02X but expect %02X", id, i, output_data[i], gold_data[i]));
    end
    $display("APP %0d passed", id);
endfunction

function void Kernel::print_input(int idx);
    foreach(input_data[idx][i]) begin
        $write("%02X ", input_data[idx][i]);
    end
    $display("\n");
endfunction

function void Kernel::print_gold(int idx);
    foreach(gold_data[idx][i]) begin
        $write("%02X ", gold_data[idx][i]);
    end
    $display("\n");
endfunction

function void Kernel::print_output(int idx);
    foreach(output_data[idx][i]) begin
        $write("%02X ", output_data[idx][i]);
    end
    $display("\n");
endfunction

function void Kernel::print_bitstream();
    foreach(bitstream[i]) begin
        $display("%16X", bitstream[i]);
    end
    $display("\n");
endfunction
