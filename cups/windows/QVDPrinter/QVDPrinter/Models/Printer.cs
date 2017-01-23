using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QVDPrinter.Models
{
    public class Printer
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public Resolution[] Resolutions { get; set; }
        public bool IsDuplex { get; set; }
        public bool IsDefaultPrinter { get; set; }
        public bool IsPlotter { get; set; }
        public int LandscapeAngle { get; set; }
        public int MaximumCopies { get; set; }
        public bool IsSupportColor { get; set; }
    }
}