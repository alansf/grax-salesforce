/* ---------------------------------------------------------------------
 * This file is subject to the terms and conditions defined in
 * file https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE,
 * which is part of this source code package.
 * ---------------------------------------------------------------------
 *          Copyright (c) 2017-2018 Harding Point
 *                  All rights reserved
 * ---------------------------------------------------------------------
 *                      Support@Grax.io
 *                      https://grax.io
 *          https://github.com/HardingPoint/GRAXForSFDC
 *   https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE
 * ---------------------------------------------------------------------*/

public class GRAXException extends Exception {

	public Double d;
	
	public GRAXException(String message, Decimal d)
    {
   		// Need to add transmission to GRAX for logging execptions.
        this(message);
        this.d = d;
    }
}
