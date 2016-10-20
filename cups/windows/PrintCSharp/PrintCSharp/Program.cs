using System;
using System.Collections.Generic;
using Ghostscript.NET.Processor;
using System.Drawing.Printing;

namespace PrintCSharp
{
    class Program 
    {
        
       static void Main(string[] args)
       {

                 string printerName = PrinterSettings.InstalledPrinters[0];
              string inputFile = @"C:\Users\inavarro\Downloads\pdf-sample.pdf";

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
                  switches.Add(inputFile);

                  processor.StartProcessing(switches.ToArray(), null);
              }
            /*  PrinterSettings a = new PrinterSettings();
               a.
               for (int i = 0; i < PrinterSettings.InstalledPrinters.Count; i++)
             {
                 Console.Write(
                     PrinterSettings.InstalledPrinters[i] + "" +
                     PrinterSettings.PaperSizeCollection[0].Height + 
                     "\n");
             }


              string col = PrinterSettings.InstalledPrinters[0];
              Console.Write(col);*/


        }
    
    }
}
