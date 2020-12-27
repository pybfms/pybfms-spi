'''
Created on Dec 27, 2020

@author: mballance
'''
from enum import IntEnum


class QSpiXferMode(IntEnum):
    SPI = 0
    DSPI = 1
    QSPI = 2
    QSPI_DDR = 3

