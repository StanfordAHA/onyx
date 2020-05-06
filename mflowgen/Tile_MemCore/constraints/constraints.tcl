#=========================================================================
# Design Constraints File
#=========================================================================

# This constraint sets the target clock period for the chip in
# nanoseconds. Note that the first parameter is the name of the clock
# signal in your verlog design. If you called it something different than
# clk you will need to change this. You should set this constraint
# carefully. If the period is unrealistically small then the tools will
# spend forever trying to meet timing and ultimately fail. If the period
# is too large the tools will have no trouble but you will get a very
# conservative implementation.

set clock_net  clk
set clock_name ideal_clock

create_clock -name ${clock_name} \
             -period ${dc_clock_period} \
             [get_ports ${clock_net}]

# Deal with passthru clock
set passthru_clock_net clk_pass_through
set passthru_clock_name ideal_clock_passthru

create_clock -name ${passthru_clock_name} \
             -period ${dc_clock_period} \
             [get_ports ${passthru_clock_net}]

# This constraint sets the load capacitance in picofarads of the
# output pins of your design.

set_load -pin_load $ADK_TYPICAL_ON_CHIP_LOAD [all_outputs]

# This constraint sets the input drive strength of the input pins of
# your design. We specifiy a specific standard cell which models what
# would be driving the inputs. This should usually be a small inverter
# which is reasonable if another block of on-chip logic is driving
# your inputs.

set_driving_cell -no_design_rule \
  -lib_cell $ADK_DRIVING_CELL [all_inputs]

# Now rip this driving cell off of our passthrough signals
# We are going to use an input/output slew and tighten a bit
remove_driving_cell clk_pass_through
remove_driving_cell stall
remove_driving_cell config_config_data*
remove_driving_cell config_config_addr*
remove_driving_cell config_read*
remove_driving_cell config_write*
# Drive passthru ports with a particular buffer
#set_driving_cell -lib_cell BUFFD2BWP16P90 clk_pass_through
# set_input_delay constraints for input ports
#
# Constrain INPUTS
# - make this non-zero to avoid hold buffers on input-registered designs
set i_delay [expr 0.2 * ${dc_clock_period}]
set_input_delay -clock ${clock_name} ${i_delay} [all_inputs]
# Pass through should have no input delay
set_input_delay -clock ${clock_name} 0 clk_pass_through
set_input_delay -clock ${clock_name} 0 stall
set_input_delay -clock ${clock_name} 0 config_config_data*
set_input_delay -clock ${clock_name} 0 config_config_addr*
set_input_delay -clock ${clock_name} 0 config_read*
set_input_delay -clock ${clock_name} 0 config_write*

# Constrain OUTPUTS
# set_output_delay constraints for output ports
set o_delay [expr 0.0 * ${dc_clock_period}]
set_output_delay -clock ${clock_name} ${o_delay} [all_outputs]

# Set timing on pass through clock
# Set clock min delay and max delay
set clock_max_delay 0.05
set_min_delay -from clk_pass_through -to clk*out 0
set_max_delay -from clk_pass_through -to clk*out ${clock_max_delay}

# Min and max delay a little more than our clock
#set min_w_in [expr ${clock_max_delay} + ${i_delay}]
set min_w_in ${clock_max_delay}
set_min_delay -to config_out_config_addr* ${min_w_in}
set_min_delay -to config_out_config_data* ${min_w_in}
set_min_delay -to config_out_read* ${min_w_in}
set_min_delay -to config_out_write* ${min_w_in}
set_min_delay -to stall_out* ${min_w_in}

# Pass through (not clock) timing margin
set alt_passthru_margin 0.03
set alt_passthru_max [expr ${min_w_in} + ${alt_passthru_margin}]
set_max_delay -to config_out_config_addr* ${alt_passthru_max}
set_max_delay -to config_out_config_data* ${alt_passthru_max}
set_max_delay -to config_out_read* ${alt_passthru_max}
set_max_delay -to config_out_write* ${alt_passthru_max}
set_max_delay -to stall_out* ${alt_passthru_max}

# 5fF approx load
set mark_approx_cap 0.005
set_load ${mark_approx_cap} config_out_config_addr*
set_load ${mark_approx_cap} config_out_config_data*
set_load ${mark_approx_cap} config_out_read* 
set_load ${mark_approx_cap} config_out_write*
set_load ${mark_approx_cap} stall_out*

# Set max transition on these outputs as well
set max_trans_passthru .1
set_max_transition ${max_trans_passthru} config_out_config_addr*
set_max_transition ${max_trans_passthru} config_out_config_data*
set_max_transition ${max_trans_passthru} config_out_read* 
set_max_transition ${max_trans_passthru} config_out_write*
set_max_transition ${max_trans_passthru} stall_out*

# Set input transition to match the max transition on outputs
set_input_transition ${max_trans_passthru} clk_pass_through
set_input_transition ${max_trans_passthru} stall
set_input_transition ${max_trans_passthru} config_config_data*
set_input_transition ${max_trans_passthru} config_config_addr*
set_input_transition ${max_trans_passthru} config_read*
set_input_transition ${max_trans_passthru} config_write*
#
# Set max delay on REGOUT paths?

# Constrain config_read_out
#
# Constrain Feedthrough FIFO bypass
#
# Constrain SB to ~100 ps
set sb_delay 0.150
# Use this first command to constrain all feedthrough paths to just the desired SB delay
set_max_delay -from SB*_IN_* -to SB*_OUT_* [expr ${sb_delay} + ${i_delay} + ${o_delay}]
# Then override the rest of the paths to be full clock period
set_max_delay -from SB*_IN_* -to SB*_OUT_* -through [get_pins [list CB*/* DECODE*/* MemCore_inst0*/* FEATURE*/*]] ${dc_clock_period}

# Make all signals limit their fanout
set_max_fanout 20 $dc_design_name

# Make all signals meet good slew

set_max_transition [expr 0.25*${dc_clock_period}] $dc_design_name

#set_input_transition 1 [all_inputs]
#set_max_transition 10 [all_outputs]

