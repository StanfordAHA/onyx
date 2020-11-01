#ifndef GLB_MAP_LIBRARY_H
#define GLB_MAP_LIBRARY_H

int glb_map(void *kernels, int num_app);
int glb_map_(struct KernelInfo *kernel);
void update_io_configuration(struct IOInfo *io_info);
void update_bs_configuration(struct BitstreamInfo *bs_info);
void add_config(struct ConfigInfo *config_info, int addr, int data);
void update_tile_configuration(struct PlaceInfo *place_info);
void update_tile_config_table(int tile, int data);

#endif
