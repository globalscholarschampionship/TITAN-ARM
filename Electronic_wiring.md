# TITAN ARM — Electronics Wiring Plan

**Project:** TITAN ARM
**Configuration:** 6 servos, ESP32 DevKit, PCA9685 servo driver, two dual\-axis joysticks
**Status:** Preliminary wiring plan — verify the exact board and component pin labels before connecting power\.

---

## 1\. System overview

```text
                 USB / regulated logic power
                           |
                        ESP32
                    /           \
             I2C SDA/SCL      Joystick inputs
                  |                 |
              PCA9685          Joystick 1 + 2
                  |
          Servo signal channels
          CH0 CH1 CH2 CH3 CH4 CH5
           |   |   |   |   |   |
          Base Shoulder Elbow Wrist Wrist Gripper
                       tilt  roll

 Separate regulated servo supply
              |
        Fuse / power switch
              |
       PCA9685 V+ and GND
```

The ESP32 sends control signals to the PCA9685\. The separate servo supply provides motor power\. **Do not power the servos from the ESP32’s 3\.3V or 5V pin\.**

## 2\. ESP32 to PCA9685 connections

|ESP32 DevKit|PCA9685|Purpose            |
|------------|-------|-------------------|
|3V3         |VCC    |PCA9685 logic power|
|GND         |GND    |Common logic ground|
|GPIO 21     |SDA    |I2C data           |
|GPIO 22     |SCL    |I2C clock          |

Use the PCA9685 board’s **V\+** terminal for the separate servo supply, not its VCC logic pin\.

## 3\. Servo channel assignments

|PCA9685 channel|Servo |Arm function  |
|---------------|------|--------------|
|CH0            |MG996R|Base rotation |
|CH1            |DS3218|Shoulder      |
|CH2            |DS3218|Elbow         |
|CH3            |MG996R|Wrist tilt    |
|CH4            |MG996R|Wrist rotation|
|CH5            |MG90S |Gripper       |

For each servo, connect its three\-wire plug to the matching channel:

- Signal wire → signal pin &#40;usually yellow, orange, or white&#41;
- Positive wire → V\+ &#40;usually red&#41;
- Ground wire → GND &#40;usually brown or black&#41;

**Check the labels and wire colours on your actual servo\.** Do not rely on colour alone\.

## 4\. Joystick connections to ESP32

This suggested pin allocation uses ESP32 ADC1 pins, which are suitable when Wi\-Fi is also used\.

|Joystick pin                   |ESP32 pin|
|-------------------------------|---------|
|Joystick 1 VRx                 |GPIO 34  |
|Joystick 1 VRy                 |GPIO 35  |
|Joystick 1 SW (optional button)|GPIO 25  |
|Joystick 2 VRx                 |GPIO 32  |
|Joystick 2 VRy                 |GPIO 33  |
|Joystick 2 SW (optional button)|GPIO 26  |
|Both joystick VCC              |3V3      |
|Both joystick GND              |GND      |

If your joystick module has different labels, check its pinout before connecting it\. Do not feed a 5V analog signal into an ESP32 input\.

## 5\. Servo power — important safety requirement

The servo supply must be a **separate regulated supply** with a voltage suitable for every installed servo\. Its current capacity must be selected using the exact models’ stall\-current specifications and the possibility of several servos moving at once\.

Before buying or connecting the supply:

1. Confirm the exact MG996R, DS3218 and MG90S variants\.
2. Find each model’s permitted voltage range and stall current\.
3. Calculate a suitable supply and wiring rating for simultaneous movement\.
4. Add an appropriately rated fuse and accessible power switch\.
5. Check connector polarity before connecting the supply to PCA9685 V\+\.

Do not assume that a small 5V adapter is sufficient\. Do not connect the servo supply’s positive output to ESP32 3V3, ESP32 5V, or PCA9685 VCC\.

**Common ground is required:** connect the servo supply negative &#40;GND&#41;, PCA9685 GND, and ESP32 GND together\. Keep the high\-current servo power wiring appropriately sized and routed separately from delicate signal wiring\.

## 6\. First power\-up checklist

- [ ] Confirm exact board and component pin labels\.
- [ ] Check all positive and ground connections for shorts\.
- [ ] Keep all servos mechanically unloaded for the first test\.
- [ ] Set safe servo pulse limits in software before movement\.
- [ ] Power the ESP32 logic and servo supply separately\.
- [ ] Test one servo at a time at a low speed and within a limited range\.
- [ ] Stop immediately if a servo buzzes heavily, overheats, stalls, or the supply voltage drops\.
- [ ] Test the emergency\-stop / power\-cut arrangement before fitting the arm\.

A software stop command is not a substitute for a physical way to disconnect servo power\.

## 7\. Still to be verified

This is a preliminary pin and architecture plan, not a tested wiring harness\. Confirm the exact ESP32 DevKit version, PCA9685 board, joystick modules, servo variants, and final power supply before making connections\. The mechanical frame’s fit and servo mounting also need to be checked against the actual kit\.

**Next build step:** identify the exact boards and servo variants, then finalize the power\-supply rating and produce a verified wiring diagram\.
