'''
Created on Apr 25, 2021

@author: mballance
'''
import cocotb
import pybfms
from fwnoc_bfms.fwnoc_channel_bfm import FwNocChannelBFM, FwNocPacket

@cocotb.test()
async def entry(dut):
    await pybfms.init()
    print("Hello")
    
    h_bfm = FwNocChannelBFM(
        pybfms.find_bfm(".*u_hi_bfm"),
        pybfms.find_bfm(".*u_he_bfm"))
    
    await h_bfm.wait_reset()
    
    pkt = FwNocPacket()
    pkt.payload.append(1)
    pkt.payload.append(2)
    
    await h_bfm.send(pkt)
    
    await cocotb.triggers.Timer(1, 'ms')
    
    