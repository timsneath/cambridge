using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace testclient
{
    class SegmentationFaultException : Exception
    {
        public SegmentationFaultException() { }
        public SegmentationFaultException(string message) : base(message) { }
        public SegmentationFaultException(string message, Exception innerException) : base(message, innerException) { }
    }
}
