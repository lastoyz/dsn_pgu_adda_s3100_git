//// PGU_algo.cs

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
//using System.Text.RegularExpressions;

namespace TopInstrument{

    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware
    using s8  = System.SByte;  // for converting firmware
    //
    using UINT32 = System.UInt32; // for converting firmware
    using INT32  = System.Int32;  // for converting firmware
    using UINT16 = System.UInt16; // for converting firmware
    using INT16  = System.Int16;  // for converting firmware
    using UINT8  = System.Byte;   // for converting firmware
    //
    using BOOL   = System.Boolean; // for converting firmware


    //// interface
    interface I_PGU_proc {} // interface for GUI SW // to come
    interface I_PGU_algo {} // interface for algorithm // to come


    //// some common class or enum or struct

    public partial class __PGU 
    {
        public enum __enum_TEST {}

    }

    //// implement

    public partial class PGU : I_PGU_proc {}
    public partial class PGU : I_PGU_algo {}

}
