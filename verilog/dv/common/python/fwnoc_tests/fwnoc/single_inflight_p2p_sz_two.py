'''
Created on May 7, 2021

@author: mballance
'''
import cocotb
from fwnoc_tests.fwnoc.fwnoc_test_base import FwnocTestBase
from fwnoc_bfms.fwnoc_channel_bfm import FwNocPacket

class SingleInflightP2P(FwnocTestBase):
    
    async def run(self):
        for src_x in range(self.size_x):
            for src_y in range(self.size_y): 
                for dst_x in range(self.size_x):
                    for dst_y in range(self.size_y):
                        if src_x == dst_x and src_y == dst_y:
                            continue
                        pkt = FwNocPacket()
                        pkt.src_tile_x = 0
                        pkt.src_tile_y = 0
                        pkt.src_tile_x = src_x
                        pkt.src_tile_y = src_y
                        pkt.dst_tile_x = 0
                        pkt.dst_tile_y = 0
                        pkt.dst_tile_x = dst_x
                        pkt.dst_tile_y = dst_y
                        pkt.payload.append(1)
                        pkt.payload.append(2)

                        print("==> (%d,%d) -> (%d,%d)" % (src_x,src_y,dst_x,dst_y))
                        await self.senders[(src_x,src_y)].send(pkt)
                        r_pkt = await self.bfms[(dst_x,dst_y)].recv()
                        print("<== (%d,%d) -> (%d,%d)" % (src_x,src_y,dst_x,dst_y))
        pass

@cocotb.test()
async def entry(dut):
    test = SingleInflightP2P()
    
    await test.init()
    await test.run()
    
    
    