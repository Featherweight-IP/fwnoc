'''
Created on May 7, 2021

@author: mballance
'''
import cocotb
from fwnoc_tests.fwnoc.fwnoc_test_base import FwnocTestBase
from fwnoc_bfms.fwnoc_channel_bfm import FwNocPacket

class SingleInflightP2P(FwnocTestBase):
    
    async def run(self):
        pkt = FwNocPacket()
        pkt.src_tile_x = 0
        pkt.src_tile_y = 0
        pkt.src_tile_x = 0
        pkt.src_tile_y = 0
        pkt.dst_tile_x = 0
        pkt.dst_tile_y = 0
        pkt.dst_tile_x = 0
        pkt.dst_tile_y = 1

        await self.senders[(0,0)].send(pkt)
        r_pkt = await self.bfms[(0,1)].recv()

@cocotb.test()
async def entry(dut):
    test = SingleInflightP2P()
    
    await test.init()
    await test.run()
    
    
    