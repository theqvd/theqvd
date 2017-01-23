using System;
using System.Collections.Generic;
using Ghostscript.NET.Processor;
using System.Drawing.Printing;


namespace QVDPrinter.Other
{
    public class PrintHelper
    {

        public void StartPrint(string printerName, string filePath)
        {
            Console.WriteLine(printerName);
            using (GhostscriptProcessor processor = new GhostscriptProcessor())
            {
                List<string> switches = new List<string>();
                switches.Add("-empty");
                switches.Add("-dPrinted");
                switches.Add("-dBATCH");
                switches.Add("-dNOPAUSE");
                switches.Add("-dNOSAFER");
                switches.Add("-dNumCopies=1");
                switches.Add("-sDEVICE=mswinpr2");
                switches.Add("-sOutputFile=%printer%" + printerName);
                switches.Add("-f");
                switches.Add(filePath);

                processor.StartProcessing(switches.ToArray(), null);
            }
        }
    }
}