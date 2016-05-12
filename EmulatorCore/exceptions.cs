using System;

namespace ProjectCambridge.EmulatorCore
{
    class SegmentationFaultException : Exception
    {
        public SegmentationFaultException() { }
        public SegmentationFaultException(string message) : base(message) { }
        public SegmentationFaultException(string message, Exception innerException) : base(message, innerException) { }
    }
}
