// Adding PNLF device for WhateverGreen.kext and others.
// This is a simplified PNLF version originally taken from RehabMan/OS-X-Clover-Laptop-Config repository:
// https://raw.githubusercontent.com/RehabMan/OS-X-Clover-Laptop-Config/master/hotpatch/SSDT-PNLF.dsl
// Rename GFX0 to anything else if your IGPU name is different.
//
// Licensed under GNU General Public License v2.0
// https://github.com/RehabMan/OS-X-Clover-Laptop-Config/blob/master/License.md

DefinitionBlock ("", "SSDT", 2, "ACDT", "PNLF", 0x00000000)
{
    External (_SB_.PCI0.GFX0, DeviceObj)    // (from opcode)

    Scope (\_SB.PCI0.GFX0)
    {
        // For backlight control
        Device (PNLF)
        {
         // Name(_ADR, Zero)
            Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
            Name (_CID, "backlight")  // _CID: Compatible ID
            // _UID is set by WhateverGreen.kext via the SUID method below, to match its internal backlight profiles.
            // See WhateverGreen/kern_weg.cpp, WEG::processPnlfUID() for the current id -> generation mapping.
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Method (SUID, 1, NotSerialized)
        {
            ^PNLF._UID = ToInteger (Arg0)
            // Return PNLF device name in case of conflict
            Return ("PNLF")
        }
    }
}
