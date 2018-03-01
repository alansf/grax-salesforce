public class GRAXException extends Exception {
	public Double d;
	
	public GRAXException(String message, Decimal d)
    {
   		// Need to add transmission to GRAX for logging execptions.
        this(message);
        this.d = d;
    }
}
