
import pybfms

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/qspi_initiator_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/qspi_initiator_bfm.v"),
    }, has_init=True)
class QSpiInitiatorBfm():

    def __init__(self):
        self.busy = pybfms.lock()
        self.is_reset = False
        self.reset_ev = pybfms.event()
        pass
        
    @pybfms.export_task()
    def _set_praameters(self):
        pass
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()
        
        
