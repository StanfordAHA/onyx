/*=============================================================================
** Module: glb_tile.sv
** Description:
**              Global Buffer Tile
** Author: Taeyoung Kong
** Change history: 01/08/2020 - Implement first version of global buffer tile
**===========================================================================*/
import global_buffer_pkg::*;

module glb_tile (
    input  logic                                                clk,
    input  logic                                                clk_en,
    input  logic                                                reset,
    input  logic [TILE_SEL_ADDR_WIDTH-1:0]                      glb_tile_id,

    // processor packet
    input  logic                                                proc_wr_en_e2w_esti,
    input  logic [BANK_DATA_WIDTH/8-1:0]                        proc_wr_strb_e2w_esti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           proc_wr_addr_e2w_esti,
    input  logic [BANK_DATA_WIDTH-1:0]                          proc_wr_data_e2w_esti,
    input  logic                                                proc_rd_en_e2w_esti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           proc_rd_addr_e2w_esti,
    input  logic [BANK_DATA_WIDTH-1:0]                          proc_rd_data_e2w_esti,
    input  logic                                                proc_rd_data_valid_e2w_esti,

    output logic                                                proc_wr_en_w2e_esto,
    output logic [BANK_DATA_WIDTH/8-1:0]                        proc_wr_strb_w2e_esto,
    output logic [GLB_ADDR_WIDTH-1:0]                           proc_wr_addr_w2e_esto,
    output logic [BANK_DATA_WIDTH-1:0]                          proc_wr_data_w2e_esto,
    output logic                                                proc_rd_en_w2e_esto,
    output logic [GLB_ADDR_WIDTH-1:0]                           proc_rd_addr_w2e_esto,
    output logic [BANK_DATA_WIDTH-1:0]                          proc_rd_data_w2e_esto,
    output logic                                                proc_rd_data_valid_w2e_esto,

    input  logic                                                proc_wr_en_w2e_wsti,
    input  logic [BANK_DATA_WIDTH/8-1:0]                        proc_wr_strb_w2e_wsti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           proc_wr_addr_w2e_wsti,
    input  logic [BANK_DATA_WIDTH-1:0]                          proc_wr_data_w2e_wsti,
    input  logic                                                proc_rd_en_w2e_wsti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           proc_rd_addr_w2e_wsti,
    input  logic [BANK_DATA_WIDTH-1:0]                          proc_rd_data_w2e_wsti,
    input  logic                                                proc_rd_data_valid_w2e_wsti,

    output logic                                                proc_wr_en_e2w_wsto,
    output logic [BANK_DATA_WIDTH/8-1:0]                        proc_wr_strb_e2w_wsto,
    output logic [GLB_ADDR_WIDTH-1:0]                           proc_wr_addr_e2w_wsto,
    output logic [BANK_DATA_WIDTH-1:0]                          proc_wr_data_e2w_wsto,
    output logic                                                proc_rd_en_e2w_wsto,
    output logic [GLB_ADDR_WIDTH-1:0]                           proc_rd_addr_e2w_wsto,
    output logic [BANK_DATA_WIDTH-1:0]                          proc_rd_data_e2w_wsto,
    output logic                                                proc_rd_data_valid_e2w_wsto,

    // stream packet
    input  logic                                                strm_wr_en_e2w_esti,
    input  logic [BANK_DATA_WIDTH/8-1:0]                        strm_wr_strb_e2w_esti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           strm_wr_addr_e2w_esti,
    input  logic [BANK_DATA_WIDTH-1:0]                          strm_wr_data_e2w_esti,
    input  logic                                                strm_rd_en_e2w_esti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           strm_rd_addr_e2w_esti,
    input  logic [BANK_DATA_WIDTH-1:0]                          strm_rd_data_e2w_esti,
    input  logic                                                strm_rd_data_valid_e2w_esti,

    output logic                                                strm_wr_en_w2e_esto,
    output logic [BANK_DATA_WIDTH/8-1:0]                        strm_wr_strb_w2e_esto,
    output logic [GLB_ADDR_WIDTH-1:0]                           strm_wr_addr_w2e_esto,
    output logic [BANK_DATA_WIDTH-1:0]                          strm_wr_data_w2e_esto,
    output logic                                                strm_rd_en_w2e_esto,
    output logic [GLB_ADDR_WIDTH-1:0]                           strm_rd_addr_w2e_esto,
    output logic [BANK_DATA_WIDTH-1:0]                          strm_rd_data_w2e_esto,
    output logic                                                strm_rd_data_valid_w2e_esto,

    input  logic                                                strm_wr_en_w2e_wsti,
    input  logic [BANK_DATA_WIDTH/8-1:0]                        strm_wr_strb_w2e_wsti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           strm_wr_addr_w2e_wsti,
    input  logic [BANK_DATA_WIDTH-1:0]                          strm_wr_data_w2e_wsti,
    input  logic                                                strm_rd_en_w2e_wsti,
    input  logic [GLB_ADDR_WIDTH-1:0]                           strm_rd_addr_w2e_wsti,
    input  logic [BANK_DATA_WIDTH-1:0]                          strm_rd_data_w2e_wsti,
    input  logic                                                strm_rd_data_valid_w2e_wsti,

    output logic                                                strm_wr_en_e2w_wsto,
    output logic [BANK_DATA_WIDTH/8-1:0]                        strm_wr_strb_e2w_wsto,
    output logic [GLB_ADDR_WIDTH-1:0]                           strm_wr_addr_e2w_wsto,
    output logic [BANK_DATA_WIDTH-1:0]                          strm_wr_data_e2w_wsto,
    output logic                                                strm_rd_en_e2w_wsto,
    output logic [GLB_ADDR_WIDTH-1:0]                           strm_rd_addr_e2w_wsto,
    output logic [BANK_DATA_WIDTH-1:0]                          strm_rd_data_e2w_wsto,
    output logic                                                strm_rd_data_valid_e2w_wsto,

    // stream data
    input  logic [CGRA_PER_GLB-1:0][CGRA_DATA_WIDTH-1:0]        stream_data_f2g,
    input  logic [CGRA_PER_GLB-1:0][0:0]                        stream_data_valid_f2g,
    output logic [CGRA_PER_GLB-1:0][CGRA_DATA_WIDTH-1:0]        stream_data_g2f,
    output logic [CGRA_PER_GLB-1:0][0:0]                        stream_data_valid_g2f,

    // Config
    // cfg_ifc.master                                              if_cfg_est_m,
    output logic                                                if_cfg_est_m_wr_en,
    output logic                                                if_cfg_est_m_wr_clk_en,
    output logic [AXI_ADDR_WIDTH-1:0]                           if_cfg_est_m_wr_addr,
    output logic [AXI_DATA_WIDTH-1:0]                           if_cfg_est_m_wr_data,
    output logic                                                if_cfg_est_m_rd_en,
    output logic                                                if_cfg_est_m_rd_clk_en,
    output logic [AXI_ADDR_WIDTH-1:0]                           if_cfg_est_m_rd_addr,
    input  logic [AXI_DATA_WIDTH-1:0]                           if_cfg_est_m_rd_data,
    input  logic                                                if_cfg_est_m_rd_data_valid,

    // cfg_ifc.slave                                               if_cfg_wst_s,
    input  logic                                                if_cfg_wst_s_wr_en,
    input  logic                                                if_cfg_wst_s_wr_clk_en,
    input  logic [AXI_ADDR_WIDTH-1:0]                           if_cfg_wst_s_wr_addr,
    input  logic [AXI_DATA_WIDTH-1:0]                           if_cfg_wst_s_wr_data,
    input  logic                                                if_cfg_wst_s_rd_en,
    input  logic                                                if_cfg_wst_s_rd_clk_en,
    input  logic [AXI_ADDR_WIDTH-1:0]                           if_cfg_wst_s_rd_addr,
    output logic [AXI_DATA_WIDTH-1:0]                           if_cfg_wst_s_rd_data,
    output logic                                                if_cfg_wst_s_rd_data_valid,

    // SRAM Config
    // cfg_ifc.master                                              if_sram_cfg_est_m,
    output logic                                                if_sram_cfg_est_m_wr_en,
    output logic                                                if_sram_cfg_est_m_wr_clk_en,
    output logic [GLB_ADDR_WIDTH-1:0]                           if_sram_cfg_est_m_wr_addr,
    output logic [CGRA_CFG_DATA_WIDTH-1:0]                      if_sram_cfg_est_m_wr_data,
    output logic                                                if_sram_cfg_est_m_rd_en,
    output logic                                                if_sram_cfg_est_m_rd_clk_en,
    output logic [GLB_ADDR_WIDTH-1:0]                           if_sram_cfg_est_m_rd_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]                      if_sram_cfg_est_m_rd_data,
    input  logic                                                if_sram_cfg_est_m_rd_data_valid,

    // cfg_ifc.slave                                               if_sram_cfg_wst_s,
    input  logic                                                if_sram_cfg_wst_s_wr_en,
    input  logic                                                if_sram_cfg_wst_s_wr_clk_en,
    input  logic [GLB_ADDR_WIDTH-1:0]                           if_sram_cfg_wst_s_wr_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]                      if_sram_cfg_wst_s_wr_data,
    input  logic                                                if_sram_cfg_wst_s_rd_en,
    input  logic                                                if_sram_cfg_wst_s_rd_clk_en,
    input  logic [GLB_ADDR_WIDTH-1:0]                           if_sram_cfg_wst_s_rd_addr,
    output logic [CGRA_CFG_DATA_WIDTH-1:0]                      if_sram_cfg_wst_s_rd_data,
    output logic                                                if_sram_cfg_wst_s_rd_data_valid,

    // trigger
    input  logic [NUM_GLB_TILES-1:0]                            strm_start_pulse_wsti,
    output logic [NUM_GLB_TILES-1:0]                            strm_start_pulse_esto,
    input  logic [NUM_GLB_TILES-1:0]                            pc_start_pulse_wsti,
    output logic [NUM_GLB_TILES-1:0]                            pc_start_pulse_esto,

    // interrupt
    input  logic [3*NUM_GLB_TILES-1:0]                          interrupt_pulse_esti,
    output logic [3*NUM_GLB_TILES-1:0]                          interrupt_pulse_wsto,

    // parallel configuration
    input  logic [0:0]                                          cgra_cfg_jtag_wsti_wr_en,
    input  logic [0:0]                                          cgra_cfg_jtag_wsti_rd_en,
    input  logic [CGRA_CFG_ADDR_WIDTH-1:0]                      cgra_cfg_jtag_wsti_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]                      cgra_cfg_jtag_wsti_data,

    input  logic [0:0]                                          cgra_cfg_jtag_esto_wr_en,
    input  logic [0:0]                                          cgra_cfg_jtag_esto_rd_en,
    input  logic [CGRA_CFG_ADDR_WIDTH-1:0]                      cgra_cfg_jtag_esto_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]                      cgra_cfg_jtag_esto_data,

    input  logic [0:0]                                          cgra_cfg_pc_wsti_wr_en,
    input  logic [0:0]                                          cgra_cfg_pc_wsti_rd_en,
    input  logic [CGRA_CFG_ADDR_WIDTH-1:0]                      cgra_cfg_pc_wsti_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]                      cgra_cfg_pc_wsti_data,

    input  logic [0:0]                                          cgra_cfg_pc_esto_wr_en,
    input  logic [0:0]                                          cgra_cfg_pc_esto_rd_en,
    input  logic [CGRA_CFG_ADDR_WIDTH-1:0]                      cgra_cfg_pc_esto_addr,
    input  logic [CGRA_CFG_DATA_WIDTH-1:0]                      cgra_cfg_pc_esto_data,

    output logic [CGRA_PER_GLB-1:0][0:0]                        cgra_cfg_g2f_cfg_wr_en,
    output logic [CGRA_PER_GLB-1:0][0:0]                        cgra_cfg_g2f_cfg_rd_en,
    output logic [CGRA_PER_GLB-1:0][CGRA_CFG_ADDR_WIDTH-1:0]    cgra_cfg_g2f_cfg_addr,
    output logic [CGRA_PER_GLB-1:0][CGRA_CFG_DATA_WIDTH-1:0]    cgra_cfg_g2f_cfg_data 
);

//============================================================================//
// glb cfg if
//============================================================================//
cfg_ifc #(.AWIDTH(AXI_ADDR_WIDTH), .DWIDTH(AXI_DATA_WIDTH)) if_cfg_est_m ();
cfg_ifc #(.AWIDTH(AXI_ADDR_WIDTH), .DWIDTH(AXI_DATA_WIDTH)) if_cfg_wst_s ();
cfg_ifc #(.AWIDTH(GLB_ADDR_WIDTH), .DWIDTH(CGRA_CFG_DATA_WIDTH)) if_sram_cfg_est_m ();
cfg_ifc #(.AWIDTH(GLB_ADDR_WIDTH), .DWIDTH(CGRA_CFG_DATA_WIDTH)) if_sram_cfg_wst_s ();

// est_m
assign if_cfg_est_m_wr_en = if_cfg_est_m.wr_en; 
assign if_cfg_est_m_wr_clk_en = if_cfg_est_m.wr_clk_en; 
assign if_cfg_est_m_wr_addr = if_cfg_est_m.wr_addr; 
assign if_cfg_est_m_wr_data = if_cfg_est_m.wr_data; 

assign if_cfg_est_m_rd_en = if_cfg_est_m.rd_en; 
assign if_cfg_est_m_rd_clk_en = if_cfg_est_m.rd_clk_en; 
assign if_cfg_est_m_rd_addr = if_cfg_est_m.rd_addr; 
assign if_cfg_est_m.rd_data = if_cfg_est_m_rd_data; 
assign if_cfg_est_m.rd_data_valid = if_cfg_est_m_rd_data_valid; 

// wst_s
assign if_cfg_wst_s.wr_en = if_cfg_wst_s_wr_en; 
assign if_cfg_wst_s.wr_clk_en = if_cfg_wst_s_wr_clk_en; 
assign if_cfg_wst_s.wr_addr = if_cfg_wst_s_wr_addr; 
assign if_cfg_wst_s.wr_data = if_cfg_wst_s_wr_data; 

assign if_cfg_wst_s.rd_en = if_cfg_wst_s_rd_en; 
assign if_cfg_wst_s.rd_clk_en = if_cfg_wst_s_rd_clk_en; 
assign if_cfg_wst_s.rd_addr = if_cfg_wst_s_rd_addr; 
assign if_cfg_wst_s_rd_data = if_cfg_wst_s.rd_data; 
assign if_cfg_wst_s_rd_data_valid = if_cfg_wst_s.rd_data_valid; 

//============================================================================//
// glb sram cfg if
//============================================================================//
// sram est_m
assign if_sram_cfg_est_m_wr_en = if_sram_cfg_est_m.wr_en; 
assign if_sram_cfg_est_m_wr_clk_en = if_sram_cfg_est_m.wr_clk_en; 
assign if_sram_cfg_est_m_wr_addr = if_sram_cfg_est_m.wr_addr; 
assign if_sram_cfg_est_m_wr_data = if_sram_cfg_est_m.wr_data; 

assign if_sram_cfg_est_m_rd_en = if_sram_cfg_est_m.rd_en; 
assign if_sram_cfg_est_m_rd_clk_en = if_sram_cfg_est_m.rd_clk_en; 
assign if_sram_cfg_est_m_rd_addr = if_sram_cfg_est_m.rd_addr; 
assign if_sram_cfg_est_m.rd_data = if_sram_cfg_est_m_rd_data; 
assign if_sram_cfg_est_m.rd_data_valid = if_sram_cfg_est_m_rd_data_valid; 

// sram wst_s
assign if_sram_cfg_wst_s.wr_en = if_sram_cfg_wst_s_wr_en; 
assign if_sram_cfg_wst_s.wr_clk_en = if_sram_cfg_wst_s_wr_clk_en; 
assign if_sram_cfg_wst_s.wr_addr = if_sram_cfg_wst_s_wr_addr; 
assign if_sram_cfg_wst_s.wr_data = if_sram_cfg_wst_s_wr_data; 

assign if_sram_cfg_wst_s.rd_en = if_sram_cfg_wst_s_rd_en; 
assign if_sram_cfg_wst_s.rd_clk_en = if_sram_cfg_wst_s_rd_clk_en; 
assign if_sram_cfg_wst_s.rd_addr = if_sram_cfg_wst_s_rd_addr; 
assign if_sram_cfg_wst_s_rd_data = if_sram_cfg_wst_s.rd_data; 
assign if_sram_cfg_wst_s_rd_data_valid = if_sram_cfg_wst_s.rd_data_valid; 

//============================================================================//
// cgra cfg jtag struct
//============================================================================//
cgra_cfg_t cgra_cfg_jtag_wsti;
cgra_cfg_t cgra_cfg_jtag_esto;

assign cgra_cfg_jtag_wsti.cfg_wr_en = cgra_cfg_jtag_wsti_wr_en;
assign cgra_cfg_jtag_wsti.cfg_rd_en = cgra_cfg_jtag_wsti_rd_en;
assign cgra_cfg_jtag_wsti.cfg_addr  = cgra_cfg_jtag_wsti_addr;
assign cgra_cfg_jtag_wsti.cfg_data  = cgra_cfg_jtag_wsti_data;

assign cgra_cfg_jtag_esto_wr_en = cgra_cfg_jtag_esto.cfg_wr_en;
assign cgra_cfg_jtag_esto_rd_en = cgra_cfg_jtag_esto.cfg_rd_en;
assign cgra_cfg_jtag_esto_addr  = cgra_cfg_jtag_esto.cfg_addr; 
assign cgra_cfg_jtag_esto_data  = cgra_cfg_jtag_esto.cfg_data; 

//============================================================================//
// cgra cfg pc struct
//============================================================================//
cgra_cfg_t cgra_cfg_pc_wsti;
cgra_cfg_t cgra_cfg_pc_esto;

assign cgra_cfg_pc_wsti.cfg_wr_en = cgra_cfg_pc_wsti_wr_en;
assign cgra_cfg_pc_wsti.cfg_rd_en = cgra_cfg_pc_wsti_rd_en;
assign cgra_cfg_pc_wsti.cfg_addr  = cgra_cfg_pc_wsti_addr;
assign cgra_cfg_pc_wsti.cfg_data  = cgra_cfg_pc_wsti_data;

assign cgra_cfg_pc_esto_wr_en = cgra_cfg_pc_esto.cfg_wr_en;
assign cgra_cfg_pc_esto_rd_en = cgra_cfg_pc_esto.cfg_rd_en;
assign cgra_cfg_pc_esto_addr  = cgra_cfg_pc_esto.cfg_addr; 
assign cgra_cfg_pc_esto_data  = cgra_cfg_pc_esto.cfg_data; 

//============================================================================//
// cgra cfg g2f struct
//============================================================================//
cgra_cfg_t cgra_cfg_g2f [CGRA_PER_GLB];
always_comb begin
    for (int i=0; i<CGRA_PER_GLB; i=i+1) begin
        cgra_cfg_g2f_cfg_wr_en[i] = cgra_cfg_g2f[i].cfg_wr_en;
        cgra_cfg_g2f_cfg_rd_en[i] = cgra_cfg_g2f[i].cfg_rd_en;
        cgra_cfg_g2f_cfg_addr[i] = cgra_cfg_g2f[i].cfg_addr;
        cgra_cfg_g2f_cfg_data[i] = cgra_cfg_g2f[i].cfg_data;
    end
end

//============================================================================//
// stream_data 2d array
//============================================================================//
logic [CGRA_DATA_WIDTH-1:0] stream_data_f2g_int [CGRA_PER_GLB];
logic [0:0]                 stream_data_valid_f2g_int [CGRA_PER_GLB];
logic [CGRA_DATA_WIDTH-1:0] stream_data_g2f_int [CGRA_PER_GLB];
logic [0:0]                 stream_data_valid_g2f_int [CGRA_PER_GLB];
always_comb begin
    for (int i=0; i<CGRA_PER_GLB; i=i+1) begin
        stream_data_f2g_int[i] = stream_data_f2g[i];
        stream_data_valid_f2g_int[i] = stream_data_f2g[i];
        stream_data_g2f[i] = stream_data_g2f_int[i];
        stream_data_valid_g2f[i] = stream_data_valid_g2f_int[i];
    end
end

//============================================================================//
// proc packet
//============================================================================//
packet_t proc_packet_w2e_wsti;
packet_t proc_packet_e2w_wsto;
packet_t proc_packet_e2w_esti;
packet_t proc_packet_w2e_esto;

assign proc_packet_w2e_wsti.wr.wr_en        = proc_wr_en_w2e_wsti;
assign proc_packet_w2e_wsti.wr.wr_strb      = proc_wr_strb_w2e_wsti;
assign proc_packet_w2e_wsti.wr.wr_addr      = proc_wr_addr_w2e_wsti;
assign proc_packet_w2e_wsti.wr.wr_data      = proc_wr_data_w2e_wsti;
assign proc_packet_w2e_wsti.rdrq.rd_en      = proc_rd_en_w2e_wsti;
assign proc_packet_w2e_wsti.rdrq.rd_addr    = proc_rd_addr_w2e_wsti;
assign proc_rd_data_w2e_wsti                = proc_packet_w2e_wsti.rdrs.rd_data;
assign proc_rd_data_valid_w2e_wsti          = proc_packet_w2e_wsti.rdrs.rd_data_valid;

assign proc_packet_e2w_wsto.wr.wr_en        = proc_wr_en_e2w_wsto;
assign proc_packet_e2w_wsto.wr.wr_strb      = proc_wr_strb_e2w_wsto;
assign proc_packet_e2w_wsto.wr.wr_addr      = proc_wr_addr_e2w_wsto;
assign proc_packet_e2w_wsto.wr.wr_data      = proc_wr_data_e2w_wsto;
assign proc_packet_e2w_wsto.rdrq.rd_en      = proc_rd_en_e2w_wsto;
assign proc_packet_e2w_wsto.rdrq.rd_addr    = proc_rd_addr_e2w_wsto;
assign proc_rd_data_e2w_wsto                = proc_packet_e2w_wsto.rdrs.rd_data;
assign proc_rd_data_valid_e2w_wsto          = proc_packet_e2w_wsto.rdrs.rd_data_valid;

assign proc_packet_e2w_esti.wr.wr_en        = proc_wr_en_e2w_esti;
assign proc_packet_e2w_esti.wr.wr_strb      = proc_wr_strb_e2w_esti;
assign proc_packet_e2w_esti.wr.wr_addr      = proc_wr_addr_e2w_esti;
assign proc_packet_e2w_esti.wr.wr_data      = proc_wr_data_e2w_esti;
assign proc_packet_e2w_esti.rdrq.rd_en      = proc_rd_en_e2w_esti;
assign proc_packet_e2w_esti.rdrq.rd_addr    = proc_rd_addr_e2w_esti;
assign proc_rd_data_e2w_esti                = proc_packet_e2w_esti.rdrs.rd_data;
assign proc_rd_data_valid_e2w_esti          = proc_packet_e2w_esti.rdrs.rd_data_valid;

assign proc_packet_w2e_esto.wr.wr_en        = proc_wr_en_w2e_esto;
assign proc_packet_w2e_esto.wr.wr_strb      = proc_wr_strb_w2e_esto;
assign proc_packet_w2e_esto.wr.wr_addr      = proc_wr_addr_w2e_esto;
assign proc_packet_w2e_esto.wr.wr_data      = proc_wr_data_w2e_esto;
assign proc_packet_w2e_esto.rdrq.rd_en      = proc_rd_en_w2e_esto;
assign proc_packet_w2e_esto.rdrq.rd_addr    = proc_rd_addr_w2e_esto;
assign proc_rd_data_w2e_esto                = proc_packet_w2e_esto.rdrs.rd_data;
assign proc_rd_data_valid_w2e_esto          = proc_packet_w2e_esto.rdrs.rd_data_valid;

//============================================================================//
// strm packet
//============================================================================//
packet_t strm_packet_w2e_wsti;
packet_t strm_packet_e2w_wsto;
packet_t strm_packet_e2w_esti;
packet_t strm_packet_w2e_esto;

assign strm_packet_w2e_wsti.wr.wr_en        = strm_wr_en_w2e_wsti;
assign strm_packet_w2e_wsti.wr.wr_strb      = strm_wr_strb_w2e_wsti;
assign strm_packet_w2e_wsti.wr.wr_addr      = strm_wr_addr_w2e_wsti;
assign strm_packet_w2e_wsti.wr.wr_data      = strm_wr_data_w2e_wsti;
assign strm_packet_w2e_wsti.rdrq.rd_en      = strm_rd_en_w2e_wsti;
assign strm_packet_w2e_wsti.rdrq.rd_addr    = strm_rd_addr_w2e_wsti;
assign strm_rd_data_w2e_wsti                = strm_packet_w2e_wsti.rdrs.rd_data;
assign strm_rd_data_valid_w2e_wsti          = strm_packet_w2e_wsti.rdrs.rd_data_valid;

assign strm_packet_e2w_wsto.wr.wr_en        = strm_wr_en_e2w_wsto;
assign strm_packet_e2w_wsto.wr.wr_strb      = strm_wr_strb_e2w_wsto;
assign strm_packet_e2w_wsto.wr.wr_addr      = strm_wr_addr_e2w_wsto;
assign strm_packet_e2w_wsto.wr.wr_data      = strm_wr_data_e2w_wsto;
assign strm_packet_e2w_wsto.rdrq.rd_en      = strm_rd_en_e2w_wsto;
assign strm_packet_e2w_wsto.rdrq.rd_addr    = strm_rd_addr_e2w_wsto;
assign strm_rd_data_e2w_wsto                = strm_packet_e2w_wsto.rdrs.rd_data;
assign strm_rd_data_valid_e2w_wsto          = strm_packet_e2w_wsto.rdrs.rd_data_valid;

assign strm_packet_e2w_esti.wr.wr_en        = strm_wr_en_e2w_esti;
assign strm_packet_e2w_esti.wr.wr_strb      = strm_wr_strb_e2w_esti;
assign strm_packet_e2w_esti.wr.wr_addr      = strm_wr_addr_e2w_esti;
assign strm_packet_e2w_esti.wr.wr_data      = strm_wr_data_e2w_esti;
assign strm_packet_e2w_esti.rdrq.rd_en      = strm_rd_en_e2w_esti;
assign strm_packet_e2w_esti.rdrq.rd_addr    = strm_rd_addr_e2w_esti;
assign strm_rd_data_e2w_esti                = strm_packet_e2w_esti.rdrs.rd_data;
assign strm_rd_data_valid_e2w_esti          = strm_packet_e2w_esti.rdrs.rd_data_valid;

assign strm_packet_w2e_esto.wr.wr_en        = strm_wr_en_w2e_esto;
assign strm_packet_w2e_esto.wr.wr_strb      = strm_wr_strb_w2e_esto;
assign strm_packet_w2e_esto.wr.wr_addr      = strm_wr_addr_w2e_esto;
assign strm_packet_w2e_esto.wr.wr_data      = strm_wr_data_w2e_esto;
assign strm_packet_w2e_esto.rdrq.rd_en      = strm_rd_en_w2e_esto;
assign strm_packet_w2e_esto.rdrq.rd_addr    = strm_rd_addr_w2e_esto;
assign strm_rd_data_w2e_esto                = strm_packet_w2e_esto.rdrs.rd_data;
assign strm_rd_data_valid_w2e_esto          = strm_packet_w2e_esto.rdrs.rd_data_valid;

//============================================================================//
// internal glb_tile instantiation
//============================================================================//
glb_tile_int glb_tile_int (
    .stream_data_f2g        (stream_data_f2g_int),
    .stream_data_valid_f2g  (stream_data_valid_f2g_int),
    .stream_data_g2f        (stream_data_g2f_int),
    .stream_data_valid_g2f  (stream_data_valid_g2f_int),
    .*);

endmodule
