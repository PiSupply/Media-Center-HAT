# Hardware

## Switches

### Buttons

* **SW1** GPIO13(PI33) up
* **SW2** GPIO17(PI11) left
* **SW3** GPIO22(PI15) bottom
* **SW4** GPIO26(PI37) right
* **SW5** GPIO27(PI13) enter
* **B1** 5 ways joystick

## Connectors

### Top of the board

* **P3** External rotary encoder
 
### Bottom of the board

* **P2** External IR receiver and LED
* **J1** Display connector
* **J2** GPIO adapter

## Jumpers

* **J3** IR selection jumper, on board or external.
    *
* **J4** ID EEPROM write protect disable jumper.
* **J5** Backlight control GPIO selection jumper, GPIO18(PI18) or GPIO12(PI32).
* **J6** Change ID EEPROM address from 0x50 to 0x51


## Pinout

#### P1 pinout
```text
P1
-----------------------------------------------------------------------------------------------------------------------
| 2     4     6     8    10    12    14    16    18    20    22    24    26    28    30    32    34    36    38    40 |
|5V    5V    GND   o     o     o     GND   o     o     GND   o     o     o     #     GND   o     GND   o     o     o  |
|3V3   o     o     o     GND   o     o     o     3V3   o     o     o     GND   #     o     o     o     o     o     GND|
| 1     3     5     7     9    11    13    15    17    19    21    23    25    27    29    31    33    35    37    39 |
-----------------------------------------------------------------------------------------------------------------------

# Used
o Available

3 I2C_SDA to MCU
5 I2C_SCL to MCU
27 I2C_SDA to HAT EEPROM
28 I2C_SDL to HAT EEPROM
```

#### P2 Pinout
```text
P2
-------------------------------
| 1     2     3     4     5   |
|VSYS  GND  GPIO5   K     A   |
-------------------------------
```

#### P3 Pinout
```text
P3
-------------------------------
| 1     2     3     4     5   |
|GND   3V3   PI13  PI15  PI37 |
-------------------------------
```

#### J2 Pinout
```text
J2
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| 1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38    39    40    MF1   MF2 |
|3V3   5V    SDA   5V    SCL   GND   PI7   PI8   GND  PI10  PI11  PI12  PI13  PI14  PI15  PI16   3V3  PI18  PI19   GND  PI21  PI22  PI23  PI24   GND  PI26  PI27  PI28  PI29   GND  PI31  PI32  PI33   GND  PI35  PI36  PI37  PI38   GND  PI40   GND   GND |
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
```

#### J3 Pinout
```text
J3
-----------------
| 2     4     6 |
|INT  IRLED  EXT|
|INT  IRREC  EXT|
| 1     3     5 |
-----------------
```

#### J4 Pinout
```text
J4
-------------
| 1     2   |
|3V3   A2/A1|
-------------
```

#### J5 Pinout
```text
J5
------------
| 2     4  |
|PI12   BL |
|PI32   BL |
| 1     3  |
------------
```

#### J6 Pinout
```text
J6
------------
| 1     2  |
|3V3   A0  |
------------
```

#### B1 Pinout
```text
B1
-----------------
| 2     4     6 |
|CT     D    CM |
| A     B     C |
| 1     3     5 |
-----------------
```

## Components

### Main active components

![Main ICs](https://user-images.githubusercontent.com/16068311/33900058-345d3218-df65-11e7-9335-7973c1a7a599.png "Main ICs")

The picture above highlights the main ICs used on PiJuice. Links to the various datasheets have been provided in line with the description.

1. **MI0283QT** [S](https://github.com/) desc
2. **ADS7846** [S](https://github.com/) desc
3. **TSOP75238W** [S](https://github.com/) desc
4. **CAT24C32** [S](https://github.com/) desc

### Unpopulated

You may notice that there are several components which have not be installed on your board. This section aims to explain what they are and which are for user customisation.

* **TP1** GND
* **TP2** 5V
* **TP3** 3V3
* **TP4** MOSI
* **TP5** MISO
* **TP6** SCK
* **TP7** LCD_CS
* **TP8** SEN_CS
* **TP9** GPIO18(PI12)
* **TP10** GPIO23(PI16)
* **TP11** GPIO24(PI18)
* **TP12** GPIO5(PI29) / IR Input Receiver
* **TP13** GPIO6(PI31) / IR Output Transmitter
* **TP14** ID_SCL(PI28)
* **TP15** ID_SDA(PI27)
* **TP16** EEPROM Write Protect
* **TP17** GPIO25(PI22) / PENIRQ (touch controller interrupt signal)
* **TP18** GPIO12(PI32)

* **R20** this is hardware configuration of reference input to touch interface chip. This is not important to users. How would use this, if necessary?

* **R21, R22 and R23** It is about to have better signal integrity on high frequency spi lines by cutting off side connection to header and cable if there for any purpose. R21, R22 and R23 should be populated in case when HAT is connected through J2 40 FPC header to RPI via GPIO adaptor board. This can be zero ohm resistors or just solder shorts.
    * **R21**  SPI MOSI, connects RPI MOSI gpio to equivalent pin 19 of J2 FPC header,
    * **R22**  SPI MISO, connects RPI MISO gpio to  equivalent pin 21 of J2 FPC header,
    * **R23**  SPI SCK, connects RPI CLK gpio to  equivalent pin 23 of J2 FPC header.

* **R9, R10** Used for display interface selection.
  * **Unpopulated** default, 4-wire 8-bit data serial SPI interface,
  * **Both populated** 3-wire 9-bit data serial SPI interface.

## Misc