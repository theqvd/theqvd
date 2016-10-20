using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Drawing.Printing;
using System.Printing;
using QVDPrinter.Models;
using QVDPrinter.Other;
using System.IO;

namespace QVDPrinter.Controllers
{
    public class PrinterController : ApiController
    {

        [HttpGet]
        public PrinterInfo GetAllPrinters()
        {
            Printer[] printers = new Printer[PrinterSettings.InstalledPrinters.Count];

            for (int i = 0; i < PrinterSettings.InstalledPrinters.Count; i++)
            {
                printers[i] = MakePrinter(i, PrinterSettings.InstalledPrinters[i]);
            }

            PrinterInfo printerInfo = new PrinterInfo();
            printerInfo.Printers = printers;

            return printerInfo;
        }

        [HttpPost]
        public async void CreatePrintJob(int id)
        {
            string a = Request.GetRouteData().Route.ToString();
            PrintHelper pe = new PrintHelper();


            //using (Stream output = File.OpenWrite("aux.pdf"))
            var readStream = this.Request.Content.ReadAsStreamAsync().Result;
            //string path = "C:\\tmp\\auxiliar.pdf";
            string path = @"C:\tmp\pdf-sample.pdf";
            //string path = @"C:\Users\inavarro\Downloads\pdf-sample.pdf";


            using (var outputStream = File.OpenWrite(path))
            {

                readStream.CopyTo(outputStream);
            }

            string col = PrinterSettings.InstalledPrinters[id];

            pe.StartPrint(col, path);

        }

        private Printer MakePrinter(int printerId, string printerName)
        {
            //We set a printer settings for the printer
            PrinterSettings settings = new PrinterSettings();
            settings.PrinterName = printerName;

            
            //Create a Printer
            Printer printer = new Printer();
            printer.Id = printerId;
            printer.Name = printerName;
            printer.Resolutions = MakeResolution(settings);
            printer.IsDuplex = settings.CanDuplex;
            printer.IsDefaultPrinter = settings.IsDefaultPrinter;
            printer.IsPlotter = settings.IsPlotter;
            printer.LandscapeAngle = settings.LandscapeAngle;
            printer.MaximumCopies = settings.MaximumCopies;
            printer.IsSupportColor = settings.SupportsColor;


            return printer;
        }

        private Resolution[] MakeResolution(PrinterSettings settings)
        {
            List<Resolution> resolutions = new List<Resolution>();
          
            for (int i = 0; i < settings.PrinterResolutions.Count; i++)
            {
                Resolution resolution = new Resolution();
                resolution.X = settings.PrinterResolutions[i].X;
                resolution.Y = settings.PrinterResolutions[i].Y;
                resolutions.Add(resolution);
            }
                        
            return resolutions.FindAll(x => x.X > 0 & x.Y > 0).ToArray();
        }

    }
}
