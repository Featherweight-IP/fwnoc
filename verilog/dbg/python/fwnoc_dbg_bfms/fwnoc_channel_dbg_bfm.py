'''
Created on May 2, 2021

@author: mballance
'''
import pybfms

@pybfms.bfm(
    hdl={
        pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/fwnoc_channel_dbg_bfm.sv"),
        pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/fwnoc_channel_dbg_bfm.sv")
        },
    has_init=True)
class FwnocChannelDbgBfm(object):
    
    def __init__(self):
        self.payload = []
        self.x_id = 0
        self.y_id = 0
        self.state = 0
        self.payload_sz = 0
        self.payload_cnt = 0
        pass

    @pybfms.export_task(pybfms.uint32_t)
    def _recv(self, data):
        if self.state == 0:
            payload_sz_m = { 
                0 : 0,
                1 : 1,
                2 : 2,
                3 : 4,
                4 : 8,
                5 : 16}
            self.payload_cnt = 0
            self.payload_sz = payload_sz_m[data&0x3]
            dst_tile_x = ((data >> 30) & 0x3)
            dst_tile_y = ((data >> 28) & 0x3)
            dst_chip_x = ((data >> 26) & 0x3)
            dst_chip_y = ((data >> 24) & 0x3)
            src_tile_x = ((data >> 22) & 0x3)
            src_tile_y = ((data >> 20) & 0x3)
            src_chip_x = ((data >> 18) & 0x3)
            src_chip_y = ((data >> 16) & 0x3)
            
            header = "(%d,%d,%d,%d)->(%d,%d,%d,%d) sz=%d" % (
                src_chip_x,src_chip_y,
                src_tile_x,src_tile_y, 
                dst_chip_x,dst_chip_y,
                dst_tile_x,dst_tile_y,
                self.payload_sz)

            self._set_pkt_header(header)

            # No payload, so clear the display one cycle later            
            if self.payload_sz == 0:
                self._delta_req()
            else:
                self.state = 1
        else: 
            # Counting down until the end of the payload
            self.payload_cnt += 1
            
            if self.payload_cnt >= self.payload_sz:
                # Clear the display
                self._delta_req()
                self.state = 0
            pass
    
    def _set_pkt_header(self, header):
        self._clr_pkt_hdr()
        
        for i,c in enumerate(header.encode()):
            self._set_pkt_hdr_c(i, c)
        
    
    @pybfms.import_task()
    def _clr_pkt_hdr(self):
        pass
    
    @pybfms.import_task(pybfms.uint8_t,pybfms.uint8_t)
    def _set_pkt_hdr_c(self, idx, ch):
        pass
    
    @pybfms.import_task()
    def _delta_req(self):
        pass
    
    @pybfms.export_task()
    def _delta_ack(self):
        self._clr_pkt_hdr()
        pass
    
    @pybfms.export_task(pybfms.uint32_t, pybfms.uint32_t)
    def _set_parameters(self, x_id, y_id):
        self.x_id = x_id
        self.y_id = y_id
        
    