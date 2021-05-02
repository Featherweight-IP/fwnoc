'''
Created on Apr 25, 2021

@author: mballance
'''
from rv_bfms.rv_data_out_bfm import ReadyValidDataOutBFM
from rv_bfms.rv_data_in_bfm import ReadyValidDataInBFM
import pybfms
import vsc

@vsc.randobj
class FwNocPacket(object):
    
    def __init__(self, tx=0, ty=0, cx=0, cy=0):
        self.src_tile_x = vsc.bit_t(2)
        self.src_tile_y = vsc.bit_t(2)
        self.src_chip_x = vsc.bit_t(2)
        self.src_chip_y = vsc.bit_t(2)
        self.dst_tile_x = vsc.rand_bit_t(2, i=tx)
        self.dst_tile_y = vsc.rand_bit_t(2, i=ty)
        self.dst_chip_x = vsc.rand_bit_t(2, i=cx)
        self.dst_chip_y = vsc.rand_bit_t(2, i=cy)
        self.payload_sz = -1
        self.payload = vsc.randsz_list_t(vsc.uint32_t())
        
    @vsc.constraint
    def size_c(self):
        self.payload.size.inside(vsc.rangelist(0, 1, 2, 4, 8, 16))
        
    @vsc.constraint
    def src_dst_c(self):
        (self.dst_tile_x != self.src_tile_x) | (self.dst_tile_y != self.src_tile_y)
        
    def src_s(self) -> str:
        return "(" + str(self.src_chip_x) + "," + str(self.src_chip_y) + "," + str(self.src_tile_x) + "," + str(self.src_tile_y) + ")"
            
    def dst_s(self) -> str:
        return "(" + str(self.dst_chip_x) + "," + str(self.dst_chip_y) + "," + str(self.dst_tile_x) + "," + str(self.dst_tile_y) + ")"
    
        
    def header(self):
        payload_sz_m = {
            0 : 0,
            1 : 1,
            2 : 2,
            4 : 3,
            8 : 4,
            16 : 5}
        
        if len(self.payload) not in payload_sz_m.keys():
            raise Exception("Payload must be power of 2. Unsupported length " + 
                            str(len(self.payload)))
        
        ret = 0
        ret |= payload_sz_m[len(self.payload)]
        ret |= ((self.dst_tile_x & 0x3) << 30)
        ret |= ((self.dst_tile_y & 0x3) << 28)
        ret |= ((self.dst_chip_x & 0x3) << 26)
        ret |= ((self.dst_chip_y & 0x3) << 24)
        ret |= ((self.dst_tile_x & 0x3) << 22)
        ret |= ((self.dst_tile_y & 0x3) << 20)
        ret |= ((self.dst_chip_x & 0x3) << 18)
        ret |= ((self.dst_chip_y & 0x3) << 16)
        
        return ret
    
    @classmethod
    def mk(cls, header) -> 'FwNocPacket':
        payload_sz_m = {
            0 : 0,
            1 : 1,
            2 : 2,
            3 : 4,
            4 : 8,
            5 : 16}
        
        ret = 0
        # TODO: should be source?
        dst_tile_x = ((header >> 30) & 0x3)
        dst_tile_y = ((header >> 28) & 0x3)
        dst_chip_x = ((header >> 26) & 0x3)
        dst_chip_y = ((header >> 24) & 0x3)
        
        pkt = FwNocPacket(
            dst_tile_x, 
            dst_tile_y, 
            dst_chip_x, 
            dst_chip_y)
        pkt.src_tile_x = ((header >> 22) & 0x3)
        pkt.src_tile_y = ((header >> 20) & 0x3)
        pkt.src_chip_x = ((header >> 18) & 0x3)
        pkt.src_chip_y = ((header >> 16) & 0x3)
        
        pkt.payload_sz = payload_sz_m[header & 0x3]
        
        return pkt
        

class FwNocChannelBFM(object):
    
    def __init__(self,
            ingress : ReadyValidDataOutBFM,
            egress : ReadyValidDataInBFM):
        self.ingress = ingress
        self.egress = egress
        self.busy = pybfms.lock()
        self.pkt =  None
        
        self.egress.add_recv_cb(self._recv)
        
        self.recv_cb = []
        
    def add_recv_cb(self, cb):
        self.recv_cb.append(cb)
        
    def del_recv_cb(self, cb):
        self.recv_cb.remove(cb)
        
    async def wait_reset(self):
        await self.egress.wait_reset()

    async def send(self, pkt : FwNocPacket):
        await self.busy.acquire()
        await self.ingress.send(pkt.header())
        
        for dat in pkt.payload:
            await self.ingress.send(dat)
            
        self.busy.release()
            
    async def recv(self) -> FwNocPacket:
        ev = pybfms.event()
        def _recv(pkt):
            nonlocal ev
            ev.set(pkt)

        pkt = await ev.wait()
                   
        return pkt 

    def _recv(self, data):
        if self.pkt is None:
            self.pkt = FwNocPacket.mk(data)
            print("Begin: payload_sz=" + str(self.pkt.payload_sz))
        else:
            self.pkt.payload.append(data)
            print("Recv: current payload_sz=" + str(len(self.pkt.payload)))
            
            if len(self.pkt.payload) >= self.pkt.payload_sz:
                for cb in self.recv_cb.copy():
                    cb(self.pkt)
                self.pkt = None
        
            

        