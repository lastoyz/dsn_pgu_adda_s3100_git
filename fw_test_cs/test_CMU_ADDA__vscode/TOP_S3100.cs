//// TOP_S3100.cs
// class inheritance control for S3100


using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text.RegularExpressions;

namespace TopInstrument{

    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware
    //
    using UINT32 = System.UInt32; // for converting firmware
    using INT32  = System.Int32;  // for converting firmware
    using UINT16 = System.UInt16; // for converting firmware
    using INT16  = System.Int16;  // for converting firmware
    using UINT8  = System.Byte;   // for converting firmware
    //
    using BOOL   = System.Boolean; // for converting firmware

    //// some common interface


    //// some common class or enum or struct
    using TSmuCtrlReg = __struct_TSmuCtrlReg;
    using TSmuCtrl    = __struct_TSmuCtrl;


    //// inheritance control for SMU
    //public partial class __S3100_CPU_BASE : __HVSMU {} // note: __HVSMU has END-POINT ADDRESS for HVSMU // __enum_EPA
    public partial class __S3100_SPI_EMUL : __HVSMU {} // note: __HVSMU has END-POINT ADDRESS for HVSMU // __enum_EPA
    public partial class EPS : __S3100_SPI_EMUL {} // __S3100_SPI_EMUL vs __S3100_CPU_BASE
    public partial class SMU : EPS {}


    //// inheritance control for CMU
    // public partial class __S3100_SPI_EMUL : __CMU {} // for __enum_EPA
    // public partial class EPS : __S3100_SPI_EMUL {} 
    // public partial class CMU : EPS {}


    //// inheritance control for PGU
    // public partial class __S3100_SPI_EMUL : __PGU {} // for __enum_EPA
    // public partial class EPS : __S3100_SPI_EMUL {} 
    // public partial class PGU : EPS {}


    
}
