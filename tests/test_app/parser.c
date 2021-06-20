#include "parser.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ERROR 1
#define SUCCESS 0
#define GROUP_SIZE 4

// statically allocated to avoid calling
static struct KernelInfo kernel_info_list[MAX_NUM_KERNEL];
static int kernel_info_index = 0;
static struct BitstreamInfo bitstream_info_list[MAX_NUM_KERNEL];
static int bitstream_info_index = 0;
static struct IOInfo io_info_list[MAX_NUM_KERNEL * MAX_NUM_IO];
static int io_info_index = 0;

// parse the place file to calculate the number of columns used
int parse_num_group(struct KernelInfo *info) {

    char *filename = info->placement_filename;

    FILE *fp;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    int max_x = 0;
    char buffer[8][BUFFER_SIZE];

    fp = fopen(filename, "r");
    if (fp == NULL) {
        printf("Could not open file %s", filename);
        return ERROR;
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        if (read == 0) continue;
        if (line[0] == '-' || line[0] == 'B') continue;

        // we parse one char at a time
        int idx = 0, buf_index = 0;
        char c;
        int count = 0;
        do {
            c = line[idx];
            if (c == ' ' || c == '\t' || c == '\n') {
                // this is one token
                if (count > 0) {
                    buffer[buf_index][count] = '\0';
                    buf_index++;
                    count = 0;
                }
            } else {
                buffer[buf_index][count] = c;
                count++;
            }
            idx++;
        } while (c != EOF && c != '\n' && idx < read);
        if (buf_index < 4) continue;
        char *s_x = buffer[1];
        char *s_y = buffer[2];
        int x = atoi(s_x);// NOLINT
        int y = atoi(s_y);// NOLINT

        if (x > max_x) max_x = x;
    }

    info->num_groups = (max_x + GROUP_SIZE - 1) / GROUP_SIZE;

    // clean up
    fclose(fp);
    if (line) free(line);
    return SUCCESS;
}

void *parse_io(json_t const* io_json, enum IO io) {
    if (io_info_index >= MAX_NUM_KERNEL*MAX_NUM_IO) return NULL;
    struct IOInfo *io_info = &io_info_list[io_info_index++];

    io_info->io = io;
    int num_input_tiles = 0, num_output_tiles = 0;

	json_t const* shape_json = json_getProperty( io_json, "shape" );
    if ( !shape_json || JSON_ARRAY != json_getType( shape_json ) ) {
        puts("Error, the shape property is not found.");
        exit(1);
    }

    int dim[8];
    int innermost_dim;
    int cnt = 0;
    json_t const* dim_json;
    for(dim_json = json_getChild( shape_json ); 
            dim_json != 0; dim_json = json_getSibling( dim_json )) {
        dim[cnt] = json_getValue(dim_json);
        cnt++;
    }

    // If the number of io_tiles is larger than 1, then the number of io_tiles
    // should be equal to the innermost_dim

    // parse io_tile list
	json_t const* io_tile_list_json = json_getProperty( io_json, "io_tiles" );
    if ( !io_tile_list_json || JSON_ARRAY != json_getType( io_tile_list_json ) ) {
        puts("Error, the io_tiles property is not found.");
        exit(1);
    }

    // parse each io_tile
    int cnt = 0;
    json_t const* io_tile_json;
    for(io_tile_json = json_getChild( io_tile_list_json ); 
            io_tile_json != 0; io_tile_json = json_getSibling( io_tile_json )) {
        if ( JSON_OBJ == json_getType( input_json ) ) {
        dim[cnt] = json_getValue(dim_json);
        cnt++;
    }

    // TODO: 


    return io_info;
}


void *parse_bitstream(char *filename) {
    if (bitstream_info_index >= MAX_NUM_KERNEL) return NULL;
    struct BitstreamInfo *bs_info = &bitstream_info_list[bitstream_info_index++];
    FILE *fp;

    int num_bs = 0;

    // count the number of lines in bitstream file and store it to bs_info->size
    if (filename[0] != '\0') {
        fp = fopen(filename, "r");
        if (fp == NULL) {
            printf("Could not open file %s", filename);
            return 0;
        }
        for (char c = getc(fp); c != EOF; c = getc(fp)) {
            if (c == '\n') // Increment count if this character is newline
                num_bs++;
        }
        fclose(fp);
    }
    // add 1 because the last line does not have new line
    num_bs++;
    bs_info->size = num_bs;

    return bs_info;
}

>>>>>>> [WIP] inside docker


void *parse_metadata(char *filename) {
    if (kernel_info_index >= MAX_NUM_KERNEL) return NULL;
    struct KernelInfo *info = &kernel_info_list[kernel_info_index++];

    FILE *fp;
    char *json_buffer = NULL;
    size_t len = 0;
    ssize_t read;
    long l_size;
    int cnt;

    fp = fopen(filename, "rb");
    if (fp == NULL) {
        return NULL;
    }

    // get current directory
    char *dir;
    // Need to free directory
    dir = get_prefix(filename, '/');

    // calculate metadata file size and save it to l_size
    fseek(fp, 0L, SEEK_END);
    l_size = ftell(fp);
    rewind(fp);

    // allocate memory for entire content
    json_buffer = malloc(l_size + 1);
    if (!json_buffer) {
        fclose(fp);
        fputs("memory allocation fails", stderr);
        exit(1);
    }

    // copy the file into the buffer
    if (fread(json_buffer, l_size, 1, fp) != 1) {
        fclose(fp);
        fputs("json file read fails", stderr);
        exit(1);
    }
    
    // parse json file
    json_t pool[MAX_JSON_FIELDS];
    json_t const* json = json_create(json_buffer, pool, MAX_JSON_FIELDS);
    if (!json) {
        fputs("Error json create", stderr);
        exit(1);
    }

    // Parse testing field
	json_t const* testing_json = json_getProperty( json, "testing" );
    if ( !testing_json || JSON_OBJ != json_getType( testing_json ) ) {
        puts("Error, the testing property is not found.");
        exit(1);
    }

    // parse coreir field
	json_t const* coreir_json = json_getProperty( testing_json, "coreir" );
    if ( !coreir_json || JSON_TEXT != json_getType( coreir_json ) ) {
        puts("Error, the coreir property is not found.");
        exit(1);
    }
    strncpy(info->coreir_filename, json_getValue(coreir_json), BUFFER_SIZE);


    // parse bistream field
	json_t const* bs_json = json_getProperty( testing_json, "bitstream" );
    if ( !bs_json || JSON_TEXT != json_getType( bs_json ) ) {
        puts("Error, the bitstream property is not found.");
        exit(1);
    }
    strncpy(info->bitstream_filename, json_getValue(bs_json), BUFFER_SIZE);

    // parse placement field
	json_t const* place_json = json_getProperty( testing_json, "placement" );
    if ( !place_json || JSON_TEXT != json_getType( place_json ) ) {
        puts("Error, the placement property is not found.");
        exit(1);
    }
    strncpy(info->placement_filename, json_getValue(place_json), BUFFER_SIZE);

    // store placement to bitstream_info
    strncpy(info->bitstream_filename, json_getValue(bs_json), BUFFER_SIZE);

    // store bitstream to bitstream_info

    // TODO: bitstream Config info should be stored elsewhere
    // the size of bitstream will be saved in bitstrea_info
    info->bitstream_info = parse_bitstream(info->bitstream_filename);

    // Parse IO scheduling information 
	json_t const* IOs_json = json_getProperty( json, "IOs" );

    // parse inputs
	json_t const* input_list_json = json_getProperty( IOs_json, "inputs" );
    if ( !input_list_json || JSON_ARRAY != json_getType( input_list_json ) ) {
        puts("Error, the input list property is not found.");
        exit(1);
    }

    json_t const* input_json;
    for( input_json = json_getChild( input_list_json ), cnt = 0;
         input_json != 0; input_json = json_getSibling( input_json ), cnt++) {
        if ( JSON_OBJ == json_getType( input_json ) ) {
            info->input_info[cnt] = parse_io(input_json, Input);
        }
    }
    info->num_inputs = cnt;

    // parse outputs
	json_t const* output_list_json = json_getProperty( IOs_json, "outputs" );
    if ( !output_list_json || JSON_ARRAY != json_getType( output_list_json ) ) {
        puts("Error, the output list property is not found.");
        exit(1);
    }

    json_t const* output_json;
    for( output_json = json_getChild( output_list_json ), cnt = 0;
         output_json != 0; output_json = json_getSibling( output_json ), cnt++) {
        if ( JSON_OBJ == json_getType( output_json ) ) {
            info->output_info[cnt] = parse_io(output_json, Output);
        }
    }
    info->num_outputs = cnt;

    // parse interleaved_input field
	json_t const* input_data_list_json = json_getProperty( testing_json, "interleaved_input" );
    if ( !input_data_list_json || JSON_ARRAY != json_getType( input_data_list_json ) ) {
        puts("Error, the interleaved_input property is not found.");
        exit(1);
    }

    json_t const* input_data_json;
    for(input_data_json = json_getChild( input_data_list_json ), cnt = 0;
		input_data_json != 0; input_data_json = json_getSibling( input_data_json ), cnt++) {
        if ( JSON_TEXT == json_getType( input_data_json ) ) {
            strncpy(info->input_info[cnt]->filename, json_getValue(input_data_json), BUFFER_SIZE);
        }
    }

    // parse interleaved_output field
	json_t const* gold_data_list_json = json_getProperty( testing_json, "interleaved_output" );
    if ( !gold_data_list_json || JSON_ARRAY != json_getType( gold_data_list_json ) ) {
        puts("Error, the interleaved_output property is not found.");
        exit(1);
    }

    json_t const* gold_data_json;
    for( gold_data_json = json_getChild( gold_data_list_json ), cnt = 0; \
		 gold_data_json != 0; gold_data_json = json_getSibling( gold_data_json ), cnt++ ) {
        if ( JSON_TEXT == json_getType( gold_data_json ) ) {
            strncpy(info->output_info[cnt]->filename, json_getValue(gold_data_json), BUFFER_SIZE);
        }
    }

    // parse number of groups
    // TODO: make a better way to calculate number of groups used
    // update scheduling group size by parsing place file
    parse_num_group(info);

    // set reset_port
    // for now we assume soft reset is always placed to the fist column by pnr
    info->reset_port = 0;

    
    // free up the buffer and close fp
    fclose(fp);
    free(dir);
    free(json_buffer);

    return info;
}

// void *get_place_info(void *info) {
//     GET_KERNEL_INFO(info);
//     return kernel_info->place_info;
// }
// 
// void *get_bs_info(void *info) {
//     GET_KERNEL_INFO(info);
//     return kernel_info->bitstream_info;
// }
// 
// void *get_input_info(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return &place_info->inputs[index];
// }
// 
// void *get_output_info(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return &place_info->outputs[index];
// }
// 
// int get_num_groups(void *info) {
//     GET_PLACE_INFO(info);
//     return place_info->num_groups;
// }
// 
// int get_group_start(void *info) {
//     GET_PLACE_INFO(info);
//     return place_info->group_start;
// }
// 
// int get_num_inputs(void *info) {
//     GET_PLACE_INFO(info);
//     return place_info->num_inputs;
// }
// 
// int get_num_outputs(void *info) {
//     GET_PLACE_INFO(info);
//     return place_info->num_outputs;
// }
// 
// int get_input_x(void *info, int index) {
//     GET_PLACE_INFO(info);
//     if (index >= place_info->num_inputs) {
//         return -1;
//     } else {
//         return place_info->inputs[index].pos.x;
//     }
// }
// 
// int get_input_y(void *info, int index) {
//     GET_PLACE_INFO(info);
//     if (index >= place_info->num_inputs) {
//         return -1;
//     } else {
//         return place_info->inputs[index].pos.y;
//     }
// }
// 
// int get_output_x(void *info, int index) {
//     GET_PLACE_INFO(info);
//     if (index >= place_info->num_outputs) {
//         return -1;
//     } else {
//         return place_info->outputs[index].pos.x;
//     }
// }
// 
// int get_output_y(void *info, int index) {
//     GET_PLACE_INFO(info);
//     if (index >= place_info->num_outputs) {
//         return -1;
//     } else {
//         return place_info->outputs[index].pos.y;
//     }
// }
// 
// int get_reset_index(void *info) {
//     GET_PLACE_INFO(info);
//     return place_info->reset_port;
// }
// 
// char *get_placement_filename(void *info) {
//     GET_KERNEL_INFO(info);
//     return kernel_info->placement_filename;
// }
// 
// char *get_bitstream_filename(void *info) {
//     GET_KERNEL_INFO(info);
//     return kernel_info->bitstream_filename;
// }
// 
// char *get_input_filename(void *info, int index) {
//     GET_KERNEL_INFO(info);
//     return kernel_info->input_filenames[index];
// }
// 
// char *get_output_filename(void *info, int index) {
//     GET_KERNEL_INFO(info);
//     return kernel_info->output_filenames[index];
// }
// 
// int get_input_size(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return place_info->input_size[index];
// }
// 
// int get_input_start_addr(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return place_info->inputs[index].start_addr;
// }
// 
// int get_input_tile(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return place_info->inputs[index].tile;
// }
// 
// int get_output_size(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return place_info->output_size[index];
// }
// 
// int get_output_start_addr(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return place_info->outputs[index].start_addr;
// }
// 
// int get_output_tile(void *info, int index) {
//     GET_PLACE_INFO(info);
//     return place_info->outputs[index].tile;
// }
// 
// int get_bs_start_addr(void *info) {
//     GET_BS_INFO(info);
//     return bs_info->start_addr;
// }
// 
// int get_bs_size(void *info) {
//     GET_BS_INFO(info);
//     return bs_info->size;
// }
// 
// int get_bs_tile(void *info) {
//     GET_BS_INFO(info);
//     return bs_info->tile;
// }
// 
static char *get_prefix(const char *s, char t)
{
    // store the last word after 't' to last (including 't')
    const char * last = strrchr(s, t);
    if(last != NULL) {
        const size_t len = (size_t) (last - s);
        char * const n = malloc(len + 2);
        memcpy(n, s, len);
        n[len] = '/';
        n[len+1] = '\0';
        return n;
    } else {
        char * const n = malloc(3);
        strcpy(n, "./\0");
        return n;
    }
}
