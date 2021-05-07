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
                        pkt1 = FwNocPacket()
                        pkt1.src_tile_x = 0
                        pkt1.src_tile_y = 0
                        pkt1.src_tile_x = src_x
                        pkt1.src_tile_y = src_y
                        pkt1.dst_tile_x = 0
                        pkt1.dst_tile_y = 0
                        pkt1.dst_tile_x = dst_x
                        pkt1.dst_tile_y = dst_y
                        pkt1.payload.append(1)
                        pkt1.payload.append(2)
                        pkt2 = FwNocPacket()
                        pkt2.src_tile_x = 0
                        pkt2.src_tile_y = 0
                        pkt2.src_tile_x = dst_x
                        pkt2.src_tile_y = dst_y
                        pkt2.dst_tile_x = 0
                        pkt2.dst_tile_y = 0
                        pkt2.dst_tile_x = src_x
                        pkt2.dst_tile_y = src_y
                        pkt2.payload.append(1)
                        pkt2.payload.append(2)

                        print("==> (%d,%d) <-> (%d,%d)" % (src_x,src_y,dst_x,dst_y))
                        cocotb.fork(self.senders[(src_x,src_y)].send(pkt1))
                        cocotb.fork(self.senders[(dst_x,dst_y)].send(pkt2))
                        print("--> await src_x,src_y")
                        r_pkt = await self.bfms[(src_x,src_y)].recv()
                        print("<-- await src_x,src_y")
#                        print("--> await dst_x,dst_y")
#                        r_pkt = await self.bfms[(dst_x,dst_y)].recv()
#                        print("<-- await dst_x,dst_y")
                        print("<== (%d,%d) <-> (%d,%d)" % (src_x,src_y,dst_x,dst_y))
        pass

@cocotb.test()
async def entry(dut):
    test = SingleInflightP2P()
    
    await test.init()
    await test.run()
    
    
    