/*=============================================================================
** Module: proc_generator.sv
** Description:
**              class for processor packet generator
** Author: Taeyoung Kong
** Change history:
**  04/18/2020 - Implement first version
**===========================================================================*/

class ProcGenerator;

    // declare processor packet transaction class
    ProcTransaction blueprint, trans;

    // declaring mailbox
    mailbox gen2drv;

    // event
    event gen2env;
    event drv2gen;

    extern function new(mailbox gen2drv, event drv2gen, event gen2env);
    extern task run();

endclass

function ProcGenerator::new(mailbox gen2drv, event drv2gen, event gen2env);
    this.gen2drv = gen2drv;
    this.drv2gen = drv2gen;
    this.gen2env = gen2env;
endfunction

task ProcGenerator::run();
    if (!blueprint.randomize()) $fatal("Proc Gen:: trans randomization failed");
    blueprint.post_randomize();
    $cast(trans, blueprint.copy());

    // print transaction info
    trans.display();

    // increase the number of transaction
    trans.no_trans++;

    gen2drv.put(trans);

    // waiting for driver to finish with it
    @drv2gen;

    ->gen2env;
endtask

